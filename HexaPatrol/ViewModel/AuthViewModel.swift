//
//  AuthViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import Foundation
import Combine
import CoreData

// Define the base URL for your API
struct BaseURL {
    static let url = URL(string: "http://127.0.0.1:8000/api/")!
    
    // Define the specific endpoints
    static var login: URL { return url.appendingPathComponent("login") }
    static var logout: URL { return url.appendingPathComponent("logout") }
    static var hirarkiData: URL { return url.appendingPathComponent("hirarki-data") }
}

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var plants: [PlantData] = []
    @Published var loginMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
//    private let context = PersistenceController.shared.context
    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext
    
    // Use the BaseURL to access endpoints
    private let loginURL = BaseURL.login
    private let logoutURL = BaseURL.logout
    private let hirarkiURL = BaseURL.hirarkiData

    @Published private var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: "userToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "userToken")
            }
        }
    }
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "userToken")
        self.isLoggedIn = self.token != nil
        loadUserData()
        Task {
            do {
                self.plants = try await loadHierarchyData()
                print("Hierarchy data loaded on app startup.")
            } catch {
                print("Error loading hierarchy data on app startup: \(error)")
            }
        }
    }

    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        }
    }
    
    private func saveUserData() {
        if let user = self.user {
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "userData")
                print("Users data saved successfully. Data: \(user)")
            }
        }
    }

    // Login method
    func login(email: String, password: String) async {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print the raw response body for troubleshooting
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Raw Response Login: \(responseBody)")
//            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                loginMessage = "Failed to login. Unknown error occurred."
                return
            }
            
            if httpResponse.statusCode == 200 {
                clearErrorMessage()
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                self.user = decodedResponse.data.user
                self.token = decodedResponse.data.token
                self.isLoggedIn = true
                self.loginMessage = "Login successful. Welcome \(self.user?.name ?? "User")!"
                
                // Save user and plant data after successful login
                saveUserData()
                
                await fetchHirarkiData()
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                    self.loginMessage = "Login failed: \(errorResponse.message)"
                } else {
                    self.errorMessage = "Unknown error occurred."
                    self.loginMessage = "Login failed. Unable to parse error message."
                }
            }
        } catch {
            loginMessage = "An error occurred: \(error.localizedDescription)"
        }
    }

    // Fetch Hirarki data
//    func fetchHirarkiData() async {
//        guard let token = token else { return }
//
//        var request = URLRequest(url: hirarkiURL)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Raw Response Hirarki: \(responseBody)")
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                return
//            }
//            
//            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.plants = decodedResponse.data
//    //                print("Fetched hirarki: \(self.plants)")
//                       if !self.plants.isEmpty {
////                           self.saveHirarkiData()
//                       } else {
//                           print("No data to save. Plants array is empty.")
//                       }
//                }
//    //            saveUserData()
//            } catch {
//                print("Error fetching plant data: \(error)")
//            }
//    }
    
    // MARK: - Hierarchy Data Fetching
//    func fetchHirarkiData() async {
//        guard let token = token else {
//            errorMessage = "No authentication token available"
//            return
//        }
//        
//        var request = URLRequest(url: hirarkiURL)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Raw Response Hierarchy: \(responseBody)")
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                errorMessage = "Invalid response type"
//                return
//            }
//            
//            guard httpResponse.statusCode == 200 else {
//                errorMessage = "Server error: \(httpResponse.statusCode)"
//                return
//            }
//            
//            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
//            print("cek decode HierarchyResponse")
//            self.plants = decodedResponse.data
//            
//            if !self.plants.isEmpty {
//                print("Starting to save hierarchy data")
////                await saveHierarchyData()
////                print("Cek Cok")
//                do {
//                    await saveHierarchyData()
//                    print("Successfully completed saveHierarchyData")
//                } catch {
//                    print("Error in saveHierarchyData: \(error)")
//                    errorMessage = "Error saving hierarchy data: \(error.localizedDescription)"
//                }
//            } else {
//                print("No data to save. Plants array is empty.")
//            }
//            
//        } catch {
//            errorMessage = "Error fetching hierarchy data: \(error.localizedDescription)"
//            print("Error details: \(error)")
//        }
//    }
    
    func fetchHirarkiData() async {
        print("Starting fetchHirarkiData")
        
        guard let token = token else {
            errorMessage = "No authentication token available"
            print("No token available")
            return
        }
        
        var request = URLRequest(url: hirarkiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Request prepared with token")

        do {
            print("Starting network request")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseBody = String(data: data, encoding: .utf8) {
                print("Raw Response Hierarchy: \(responseBody)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response type"
                print("Invalid response type received")
                return
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "Server error: \(httpResponse.statusCode)"
                print("Non-200 status code received: \(httpResponse.statusCode)")
                return
            }
            
            print("Starting JSON decode")
            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
            print("Successfully decoded HierarchyResponse")
            
            self.plants = decodedResponse.data
            print("Plants array updated with \(self.plants.count) items")
            
            if !self.plants.isEmpty {
                print("Starting to save hierarchy data")
                do {
                    try await saveHierarchyData()
                    try context.save()
                    print("Successfully completed saveHierarchyData: \(plants)")
//                    print("Users data saved successfully. Data: \(plants)")
                } catch {
                    print("Error in saveHierarchyData: \(error)")
                    errorMessage = "Error saving hierarchy data: \(error.localizedDescription)"
                }
            } else {
                print("No data to save. Plants array is empty.")
            }
            
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            switch decodingError {
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
            case .keyNotFound(let key, let context):
                print("Key '\(key)' not found: \(context)")
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type): \(context)")
            case .valueNotFound(let type, let context):
                print("Value of type \(type) not found: \(context)")
            @unknown default:
                print("Unknown decoding error")
            }
            errorMessage = "Error decoding data: \(decodingError.localizedDescription)"
        } catch {
            print("Network or other error: \(error)")
            errorMessage = "Error fetching hierarchy data: \(error.localizedDescription)"
        }
    }

    // Logout method
    func logout() {
        guard let token = self.token else {
            return
        }
        
        var request = URLRequest(url: logoutURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.token = nil
                    self.user = nil
                    self.plants = []
                    self.isLoggedIn = false
                    self.email = ""
                    self.password = ""
                    UserDefaults.standard.removeObject(forKey: "userToken")
                    UserDefaults.standard.removeObject(forKey: "userData")
                    UserDefaults.standard.removeObject(forKey: "plantData")
                    UserDefaults.standard.removeObject(forKey: "email")
                    UserDefaults.standard.removeObject(forKey: "password")
                    UserDefaults.standard.removeObject(forKey: "savedHirarkiData")
                }
            } catch {
                print("Error during logout: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: refresh hirarki data
    func refreshHirarkiData() async {
        guard let token = self.token else {
            print("No token available for refresh")
            return
        }

        var request = URLRequest(url: hirarkiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to refresh plant data")
                return
            }
            
            // Decode the fresh data
            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.plants = decodedResponse.data
            }
            
            print("Hirarki data successfully refreshed")
        } catch {
            print("Error refreshing plant data: \(error)")
        }
    }
    
    private func saveHierarchyData() async throws {
        print("Beginning saveHierarchyData execution")
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
                                        paramEntity.ordering = Int64(param.ordering)
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
                                        paramEntity.ordering = Int64(param.ordering)
                                        // Set bidirectional relationship
                                        paramEntity.paramFromTagno = tagnoEntity
                                        tagnoEntity.addToTagnoToParam(paramEntity)
                                    }
                                }
                            }
                        }
                    }
                }
                print("Completed processing plant")
            }

            print("Attempting to save context")
            try self.context.save()
            print("Successfully saved context")
        }
    }

    
    // MARK: - Load Function
    private func loadHierarchyData() async throws -> [PlantData] {
        print("Beginning loadHierarchyData execution")
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
                                parameters.sort { $0.ordering < $1.ordering }
                                
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
            print("Successfully loaded hierarchy data")
        }
        
        return plants
    }
    

    // Clear error messages
    func clearErrorMessage() {
        self.errorMessage = ""
        self.loginMessage = ""
    }

}
