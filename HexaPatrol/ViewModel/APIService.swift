//
//  APIService.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import Foundation
import Combine
import CoreData
import SwiftUI

// MARK: - URL Configuration
struct BaseURL {
    private enum Constants {
        static let defaultURLString = "http://192.168.18.96:8000/api/"
        static let defaultURLKey = "DefaultBaseURL"
        static let currentURLKey = "BaseURL"
    }
    
    @AppStorage("BaseURL") private static var storedURL: String?
    private static var cachedURL: URL?
    
    static var defaultURL: URL {
        get {
            guard let savedDefault = UserDefaults.standard.string(forKey: Constants.defaultURLKey),
                  let url = URL(string: savedDefault) else {
                return URL(string: Constants.defaultURLString)!
            }
            return url
        }
        set {
            UserDefaults.standard.set(newValue.absoluteString, forKey: Constants.defaultURLKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var url: URL {
        get {
            if let stored = storedURL,
               let cachedURL = cachedURL,
               stored != cachedURL.absoluteString {
                self.cachedURL = nil
            }
            
            if let cached = cachedURL {
                Logger.debug("Using cached URL: \(cached.absoluteString)")
                return cached
            }
            
            if let stored = storedURL, let url = URL(string: stored) {
                Logger.debug("Using stored URL: \(stored)")
                cachedURL = url
                return url
            }
            
            Logger.warning("Using default URL: \(defaultURL)")
            return defaultURL
        }
        set {
            Logger.debug("Setting new URL: \(newValue.absoluteString)")
            storedURL = newValue.absoluteString
            cachedURL = newValue
            NotificationCenter.default.post(name: .baseURLUpdated, object: nil)
        }
    }
    
    // MARK: - API Endpoints
    static var login: URL { url.appendingPathComponent("login") }
    static var logout: URL { url.appendingPathComponent("logout") }
    static var hirarkiData: URL { url.appendingPathComponent("hirarki-data") }
    static var cantPatrolRequest: URL { url.appendingPathComponent("cant-patrol") }
    
    // MARK: - URL Management
    static func clearURLCache() {
        Logger.debug("Clearing URL cache")
        cachedURL = nil
    }
    
    static func forceUpdateURL(_ newURL: URL) {
        Logger.debug("Force updating URL to: \(newURL.absoluteString)")
        clearURLCache()
        storedURL = newURL.absoluteString
        cachedURL = newURL
        NotificationCenter.default.post(name: .baseURLUpdated, object: nil)
    }
}

    // MARK: - Notifications
    extension Notification.Name {
        static let baseURLUpdated = Notification.Name("baseURLUpdated")
    }

    // MARK: - Protocols
    protocol AuthenticationFormProtocol {
        var formIsValid: Bool { get }
    }

    // MARK: - Logger
    private enum Logger {
        static func debug(_ message: String) {
            print("📌 \(message)")
        }
        
        static func warning(_ message: String) {
            print("⚠️ \(message)")
        }
        
        static func error(_ message: String) {
            print("❌ \(message)")
        }
    }

// MARK: - AuthViewModel
@MainActor
final class APIService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var user: User?
    @Published private(set) var plants: [PlantData] = []
    @Published private(set) var loginMessage: String = ""
    @Published private(set) var errorMessage: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoggedIn: Bool = false
    @Published var locationViewModel: LocationViewModel
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    
    @Published private var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: "userToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "userToken")
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        self.locationViewModel = LocationViewModel()
        self.token = UserDefaults.standard.string(forKey: "userToken")
        self.isLoggedIn = self.token != nil
        
        setupNotifications()
        loadInitialData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Setup Methods
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleURLChange),
            name: .baseURLUpdated,
            object: nil
        )
    }
    
    private func loadInitialData() {
        loadUserData()
        
        Task {
            do {
                self.plants = try await loadHierarchyData()
            } catch {
                Logger.error("Error loading hierarchy data on app startup: \(error)")
            }
        }
    }
    
    // MARK: - Private Helper Methods
    private func verifyLoginURL() {
        Logger.debug("Verifying login URL...")
        Logger.debug("Current login URL: \(BaseURL.login.absoluteString)")
        
        if let stored = UserDefaults.standard.string(forKey: "BaseURL") {
            Logger.debug("Stored BaseURL: \(stored)")
        } else {
            Logger.warning("No stored BaseURL found")
        }
    }
    
    private func createLoginRequest(email: String, password: String) throws -> URLRequest {
        var request = URLRequest(url: BaseURL.login)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return request
    }
    
    private func handleLoginResponse(data: Data, response: URLResponse) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            loginMessage = "Failed to login. Unknown error occurred."
            errorMessage = "Failed to login. Unknown error occurred."
            return
        }
        
        if httpResponse.statusCode == 200 {
            try await handleSuccessfulLogin(data: data)
        } else {
            try handleFailedLogin(data: data)
        }
    }
    
    private func handleSuccessfulLogin(data: Data) async throws {
        clearErrorMessage()
        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        self.user = decodedResponse.data.user
        self.token = decodedResponse.data.token
        self.isLoggedIn = true
        self.loginMessage = "Login successful. Welcome \(self.user?.name ?? "User")!"
        
        saveUserData()
        await fetchHirarkiData()
        
        locationViewModel = LocationViewModel()
    }
    
    private func handleFailedLogin(data: Data) throws {
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            self.errorMessage = errorResponse.message
            self.loginMessage = "Login failed: \(errorResponse.message)"
        } else {
            self.errorMessage = "Unknown error occurred."
            self.loginMessage = "Login failed. Unable to parse error message."
        }
    }
    
    // MARK: - Save user DataPersistance
    private func saveUserData() {
        if let user = self.user {
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "userData")
                print("Users data saved successfully. Data: \(user)")
            }
        }
    }
    
    // MARK: - Load user DataPersistance
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        }
    }
    
    // MARK: - Save hirarki to CoreData
    private func saveHierarchyData() async throws {
        //        print("Beginning saveHierarchyData execution")
        let context = PersistenceController.shared.context
        
        try await context.perform {
            for plant in self.plants {
                // Check if the Plant already exists
                let plantFetchRequest: NSFetchRequest<PlantModel> = PlantModel.fetchRequest()
                plantFetchRequest.predicate = NSPredicate(format: "plantID == %d", plant.plantID)
                let existingPlants = try? self.context.fetch(plantFetchRequest)
                let plantEntity: PlantModel
                
                if let existingPlant = existingPlants?.first {
                    plantEntity = existingPlant
                    // Update any fields if necessary
                    plantEntity.plantName = plant.plantName
                } else {
                    plantEntity = PlantModel(context: self.context)
                    plantEntity.plantID = Int64(plant.plantID)
                    plantEntity.plantName = plant.plantName
                }
                
                for area in plant.areaData {
                    // Check if the Area already exists
                    let areaFetchRequest: NSFetchRequest<AreaModel> = AreaModel.fetchRequest()
                    areaFetchRequest.predicate = NSPredicate(format: "areaID == %d AND areaFromPlant.plantID == %d", area.areaID, plant.plantID)
                    let existingAreas = try? self.context.fetch(areaFetchRequest)
                    let areaEntity: AreaModel
                    
                    if let existingArea = existingAreas?.first {
                        areaEntity = existingArea
                        // Update any fields if necessary
                        areaEntity.areaName = area.areaName
                    } else {
                        areaEntity = AreaModel(context: self.context)
                        areaEntity.areaID = Int64(area.areaID)
                        areaEntity.areaName = area.areaName
                        // Set bidirectional relationship
                        areaEntity.areaFromPlant = plantEntity
                        plantEntity.addToPlantToArea(areaEntity)
                    }
                    
                    for group in area.equipmentGroup {
                        // Check if the Equipment Group already exists
                        let groupFetchRequest: NSFetchRequest<EquipmentGroupModel> = EquipmentGroupModel.fetchRequest()
                        groupFetchRequest.predicate = NSPredicate(format: "equipmentGroupID == %d AND areaFromGroup.areaID == %d", group.equipmentGroupID, area.areaID)
                        let existingGroups = try? self.context.fetch(groupFetchRequest)
                        let groupEntity: EquipmentGroupModel
                        
                        if let existingGroup = existingGroups?.first {
                            groupEntity = existingGroup
                            // Update any fields if necessary
                            groupEntity.equipmentGroupName = group.equipmentGroupName
                        } else {
                            groupEntity = EquipmentGroupModel(context: self.context)
                            groupEntity.equipmentGroupID = Int64(group.equipmentGroupID)
                            groupEntity.equipmentGroupName = group.equipmentGroupName
                            // Set bidirectional relationship
                            groupEntity.areaFromGroup = areaEntity
                            areaEntity.addToAreaToGroup(groupEntity)
                        }
                        
                        for type in group.equipmentType {
                            // Check if the Equipment Type already exists
                            let typeFetchRequest: NSFetchRequest<EquipmentTypeModel> = EquipmentTypeModel.fetchRequest()
                            typeFetchRequest.predicate = NSPredicate(format: "equipmentTypeID == %d AND typeFromGroup.equipmentGroupID == %d", type.equipmentTypeID, group.equipmentGroupID)
                            let existingTypes = try? self.context.fetch(typeFetchRequest)
                            let typeEntity: EquipmentTypeModel
                            
                            if let existingType = existingTypes?.first {
                                typeEntity = existingType
                                // Update any fields if necessary
                                typeEntity.equipmentTypeName = type.equipmentTypeName
                            } else {
                                typeEntity = EquipmentTypeModel(context: self.context)
                                typeEntity.equipmentTypeID = Int64(type.equipmentTypeID)
                                typeEntity.equipmentTypeName = type.equipmentTypeName
                                // Set bidirectional relationship
                                typeEntity.typeFromGroup = groupEntity
                                groupEntity.addToGroupToType(typeEntity)
                            }
                            
                            for tagno in type.tagno {
                                // Check if the Tagno already exists
                                let tagnoFetchRequest: NSFetchRequest<TagnoModel> = TagnoModel.fetchRequest()
                                tagnoFetchRequest.predicate = NSPredicate(format: "tagnoID == %d AND tagnoFromType.equipmentTypeID == %d", tagno.tagnoID, type.equipmentTypeID)
                                let existingTagnos = try? self.context.fetch(tagnoFetchRequest)
                                let tagnoEntity: TagnoModel
                                
                                if let existingTagno = existingTagnos?.first {
                                    tagnoEntity = existingTagno
                                    // Update any fields if necessary
                                    tagnoEntity.tagnoName = tagno.tagnoName
                                } else {
                                    tagnoEntity = TagnoModel(context: self.context)
                                    tagnoEntity.tagnoID = Int64(tagno.tagnoID)
                                    tagnoEntity.tagnoName = tagno.tagnoName
                                    // Set bidirectional relationship
                                    tagnoEntity.tagnoFromType = typeEntity
                                    typeEntity.addToTypeToTagno(tagnoEntity)
                                }
                                
                                for param in tagno.parameter {
                                    // Check if the Parameter already exists
                                    let paramFetchRequest: NSFetchRequest<ParameterModel> = ParameterModel.fetchRequest()
                                    paramFetchRequest.predicate = NSPredicate(format: "parameterID == %d AND paramFromTagno.tagnoID == %d", param.parameterID, tagno.tagnoID)
                                    let existingParams = try? self.context.fetch(paramFetchRequest)
                                    let paramEntity: ParameterModel
                                    
                                    if let existingParam = existingParams?.first {
                                        paramEntity = existingParam
                                        // Update any fields if necessary
                                        paramEntity.parameterName = param.parameterName
                                        paramEntity.unit = param.unit
                                        paramEntity.formType = param.formType
                                        paramEntity.booleanOption = param.booleanOption
                                        paramEntity.correctOption = param.correctOption
                                        paramEntity.gap = param.gap
                                        paramEntity.min = Int64(param.min!)
                                        paramEntity.max = Int64(param.max!)
                                        paramEntity.ordering = Int64(param.ordering!)
                                    } else {
                                        paramEntity = ParameterModel(context: self.context)
                                        paramEntity.parameterID = Int64(param.parameterID)
                                        paramEntity.parameterName = param.parameterName
                                        paramEntity.unit = param.unit
                                        paramEntity.formType = param.formType
                                        paramEntity.booleanOption = param.booleanOption
                                        paramEntity.correctOption = param.correctOption
                                        paramEntity.gap = param.gap
                                        paramEntity.min = Int64(param.min!)
                                        paramEntity.max = Int64(param.max!)
                                        paramEntity.ordering = Int64(param.ordering!)
                                        // Set bidirectional relationship
                                        paramEntity.paramFromTagno = tagnoEntity
                                        tagnoEntity.addToTagnoToParam(paramEntity)
                                    }
                                }
                            }
                        }
                    }
                }
                //                print("Completed processing plant")
            }
            
            //            print("Attempting to save context")
            try self.context.save()
            //            print("Successfully saved context")
        }
    }
    
    // MARK: - Load hirarki from CoreData
    private func loadHierarchyData() async throws -> [PlantData] {
        //        print("Beginning loadHierarchyData execution")
        let context = PersistenceController.shared.context
        var plants: [PlantData] = []
        
        try await context.perform {
            // Fetch all plants
            let plantRequest = PlantModel.fetchRequest()
            let plantEntities = try context.fetch(plantRequest)
            
            for plantEntity in plantEntities {
                var areas: [AreaData] = []
                
                // Load areas for each plant
                let areaEntities = plantEntity.plantToArea?.allObjects as? [AreaModel] ?? []
                for areaEntity in areaEntities {
                    var groups: [EquipmentGroup] = []
                    
                    // Load equipment groups for each area
                    let groupEntities = areaEntity.areaToGroup?.allObjects as? [EquipmentGroupModel] ?? []
                    for groupEntity in groupEntities {
                        var types: [EquipmentType] = []
                        
                        // Load equipment types for each group
                        let typeEntities = groupEntity.groupToType?.allObjects as? [EquipmentTypeModel] ?? []
                        for typeEntity in typeEntities {
                            var tagnos: [Tagno] = []
                            
                            // Load tagnos for each type
                            let tagnoEntities = typeEntity.typeToTagno?.allObjects as? [TagnoModel] ?? []
                            for tagnoEntity in tagnoEntities {
                                var parameters: [Parameter] = []
                                
                                // Load parameters for each tagno
                                let paramEntities = tagnoEntity.tagnoToParam?.allObjects as? [ParameterModel] ?? []
                                for paramEntity in paramEntities {
                                    let mandatory: Mandatory = paramEntity.mandatory ?
                                        .bool(true) : .int(0)
                                    
                                    let parameter = Parameter(
                                        parameterID: Int(paramEntity.parameterID),
                                        parameterName: paramEntity.parameterName ?? "",
                                        unit: paramEntity.unit ?? "",
                                        formType: paramEntity.formType ?? "",
                                        booleanOption: paramEntity.booleanOption ?? "",
                                        correctOption: paramEntity.correctOption ?? "",
                                        gap: paramEntity.gap ?? "",
                                        mandatory: mandatory,
                                        min: Int(paramEntity.min),
                                        max: Int(paramEntity.max),
                                        ordering: Int(paramEntity.ordering)
                                    )
                                    
                                    parameters.append(parameter)
                                }
                                
                                // Sort parameters by ordering
                                parameters.sort { $0.ordering! < $1.ordering! }
                                
                                let tagno = Tagno(
                                    tagnoID: Int(tagnoEntity.tagnoID),
                                    tagnoName: tagnoEntity.tagnoName ?? "",
                                    parameter: parameters
                                )
                                
                                tagnos.append(tagno)
                            }
                            
                            let type = EquipmentType(
                                equipmentTypeID: Int(typeEntity.equipmentTypeID),
                                equipmentTypeName: typeEntity.equipmentTypeName ?? "",
                                tagno: tagnos
                            )
                            
                            types.append(type)
                        }
                        
                        let group = EquipmentGroup(
                            equipmentGroupID: Int(groupEntity.equipmentGroupID),
                            equipmentGroupName: groupEntity.equipmentGroupName ?? "",
                            equipmentType: types
                        )
                        
                        groups.append(group)
                    }
                    
                    let area = AreaData(
                        areaID: Int(areaEntity.areaID),
                        areaName: areaEntity.areaName ?? "",
                        equipmentGroup: groups
                    )
                    
                    areas.append(area)
                }
                
                let plant = PlantData(
                    plantID: Int(plantEntity.plantID),
                    plantName: plantEntity.plantName ?? "",
                    areaData: areas
                )
                
                plants.append(plant)
            }
            //            print("Successfully loaded hierarchy data")
        }
        
        return plants
    }
    
    // MARK: - Clear all hirarki data after logged out
    private func clearCoreData() async {
        let context = PersistenceController.shared.context
        
        await context.perform {
            let entityNames = ["PlantModel", "AreaModel", "EquipmentGroupModel", "EquipmentTypeModel", "TagnoModel", "ParameterModel"]
            
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                    try context.save()
                    print("Successfully cleared data for entity: \(entityName)")
                } catch {
                    print("Failed to delete data for entity \(entityName): \(error)")
                }
            }
        }
    }
    
    // MARK: - Clear error messages
    private func clearErrorMessage() {
        self.errorMessage = ""
        self.loginMessage = ""
    }
    
    @objc private func handleURLChange() {
        errorMessage = ""
    }
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) async {
        verifyLoginURL()
        
        do {
            let request = try createLoginRequest(email: email, password: password)
            let (data, response) = try await session.data(for: request)
            
            try await handleLoginResponse(data: data, response: response)
        } catch let error as URLError {
            loginMessage = "Failed to connect to server. Please check your internet connection."
            errorMessage = "Network error: \(error.localizedDescription)"
        } catch {
            loginMessage = "An error occurred: \(error.localizedDescription)"
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Authentication Methods
    func logout() async {
        guard let token = self.token else { return }
        
        do {
            let request = createLogoutRequest(token: token)
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Invalid response type received during logout")
                return
            }
            
            if httpResponse.statusCode == 200 {
                await performLogout()
            } else {
                Logger.error("Logout failed with status code: \(httpResponse.statusCode)")
            }
        } catch {
            Logger.error("Error during logout: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods
    private func createLogoutRequest(token: String) -> URLRequest {
        var request = URLRequest(url: BaseURL.logout)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func performLogout() async {
        // Reset authentication state
        resetAuthenticationState()
        
        // Clear user data
        clearUserDefaults()
        
        // Clear Core Data
        await clearCoreData()
        
        Logger.debug("Logout completed successfully")
    }
    
    private func resetAuthenticationState() {
        token = nil
        user = nil
        plants = []
        isLoggedIn = false
        email = ""
        password = ""
    }
    
    private func clearUserDefaults() {
        let keysToRemove = [
            "userToken",
            "userData",
            "email",
            "password",
            "savedHirarkiData",
            "loadHirarkiData"
        ]
        
        keysToRemove.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - Hierarchy Data Fetching
    func fetchHirarkiData() async {
        do {
            let token = try validateToken()
            let request = createHierarchyRequest(token: token)
            let (data, response) = try await performHierarchyRequest(request)
            try await processHierarchyResponse(data: data, response: response)
        } catch AuthError.tokenMissing {
            handleError("No authentication token available")
        } catch AuthError.invalidResponse {
            handleError("Invalid response type")
        } catch AuthError.serverError(let code) {
            handleError("Server error: \(code)")
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch {
            handleError("Error fetching hierarchy data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods
    private func validateToken() throws -> String {
        guard let token = token else {
            Logger.error("No token available")
            throw AuthError.tokenMissing
        }
        return token
    }
    
    private func createHierarchyRequest(token: String) -> URLRequest {
        var request = URLRequest(url: BaseURL.hirarkiData)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        Logger.debug("Request prepared with token")
        return request
    }
    
    private func performHierarchyRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        Logger.debug("Starting network request")
        let (data, response) = try await session.data(for: request)
        
        #if DEBUG
        if let responseBody = String(data: data, encoding: .utf8) {
            Logger.debug("Raw Response Hierarchy: \(responseBody)")
        }
        #endif
        
        return (data, response)
    }
    
    private func processHierarchyResponse(data: Data, response: URLResponse) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.error("Invalid response type received")
            throw AuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            Logger.error("Non-200 status code received: \(httpResponse.statusCode)")
            throw AuthError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
        self.plants = decodedResponse.data
        
        if !plants.isEmpty {
            try await saveHierarchyData()
            try context.save()
            Logger.debug("Successfully saved hierarchy data")
        } else {
            Logger.warning("No data to save. Plants array is empty.")
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) {
        let errorMessage: String
        
        switch error {
        case .dataCorrupted(let context):
            Logger.error("Data corrupted: \(context)")
            errorMessage = "Data corruption error"
        case .keyNotFound(let key, let context):
            Logger.error("Key '\(key)' not found: \(context)")
            errorMessage = "Missing data field: \(key)"
        case .typeMismatch(let type, let context):
            Logger.error("Type mismatch for type \(type): \(context)")
            errorMessage = "Data format error"
        case .valueNotFound(let type, let context):
            Logger.error("Value of type \(type) not found: \(context)")
            errorMessage = "Missing required value"
        @unknown default:
            Logger.error("Unknown decoding error")
            errorMessage = "Unknown data error"
        }
        
        self.errorMessage = "Error decoding data: \(errorMessage)"
    }
    
    private func handleError(_ message: String) {
        Logger.error(message)
        errorMessage = message
    }
    
    enum AuthError: Error {
        case tokenMissing
        case invalidResponse
        case serverError(Int)
    }
    
    // MARK: - Hierarchy Data Refresh
    func refreshHirarkiData() async {
        do {
            let token = try validateToken()
            let request = createHierarchyRequest(token: token)
            try await refreshHierarchyData(with: request)
            Logger.debug("Hierarchy data successfully refreshed")
        } catch AuthError.tokenMissing {
            Logger.error("No token available for refresh")
        } catch {
            Logger.error("Error refreshing hierarchy data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods
    private func refreshHierarchyData(with request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.error("Invalid response type received")
            throw AuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            Logger.error("Failed to refresh hierarchy data: status code \(httpResponse.statusCode)")
            throw AuthError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
        self.plants = decodedResponse.data
    }
    
    // MARK: - Cant Patrol Request
    func postCantPatrol(
        name: String,
        username: String,
        department: String,
        role: String,
        userDate: String,
        image: UIImage,
        size: String,
        status: String,
        reason: String,
        location: String,
        lon: Decimal,
        lat: Decimal,
        reasonDate: String
    ) async throws {
        guard let token = token else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
        }
        
        let cantPatrolURL = BaseURL.url.appendingPathComponent("cant-patrol")
        
        // Generate boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Create request
        var request = URLRequest(url: cantPatrolURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var bodyData = Data()
        
        // Function to append text field
        func appendField(named name: String, value: String) {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            bodyData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add user fields
        appendField(named: "user[name]", value: name)
        appendField(named: "user[username]", value: username)
        appendField(named: "user[department]", value: department)
        appendField(named: "user[role]", value: role)
        appendField(named: "user[date]", value: userDate)
        
        // Add photo image
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let timestamp = Int(Date().timeIntervalSince1970)
//                let filename = "photo_\(timestamp).png"
            let filename = "photo_\(timestamp).jpg"
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"photo[image_name]\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
//                print("Image Data Size: \(imageData.count) bytes")
        } else {
            throw NSError(domain: "ImageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }
        
        // Add photo size
        appendField(named: "photo[size]", value: size)
        
        // Add reason transaction fields
        appendField(named: "reason_transactions[status]", value: status)
        appendField(named: "reason_transactions[reason]", value: reason)
        appendField(named: "reason_transactions[location]", value: location)
        appendField(named: "reason_transactions[lon]", value: lon.description)
        appendField(named: "reason_transactions[lat]", value: lat.description)
        appendField(named: "reason_transactions[date]", value: reasonDate)
        
        // Add final boundary
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the request body
        request.httpBody = bodyData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decodedResponse = try JSONDecoder().decode(CantPatrolResponse.self, from: data)
                print("Success: \(decodedResponse.message)")
            case 401:
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
            case 422:
                throw NSError(domain: "ValidationError", code: 422, userInfo: [NSLocalizedDescriptionKey: "Validation failed"])
            default:
                throw NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
