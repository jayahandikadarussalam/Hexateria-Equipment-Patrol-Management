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
    private var cancellables = Set<AnyCancellable>()
//    private let context = PersistenceController.shared.container.viewContext
    
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
//                self.plants = try await loadHierarchyData()
                self.plants = try await HierarchyDataPersistence.shared.loadHierarchyData()
                print("Hierarchy data loaded on app startup.")
            } catch {
                print("Error loading hierarchy data on app startup: \(error)")
            }
        }
    }

    //MARK: Login
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
    
    //MARK: Logout
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

    // MARK: - Fetch hirarki data
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
//                    try await saveHierarchyData()
                    try await HierarchyDataPersistence.shared.saveHierarchyData()
                    try HierarchyDataPersistence.shared.context.save()
                    print("Successfully completed saveHierarchyData: \(plants)")
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

    //MARK: Refresh hirarki data
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
    
    // MARK: - Clear error messages
    func clearErrorMessage() {
        self.errorMessage = ""
        self.loginMessage = ""
    }
    
//    // MARK: - Save user DataPersistance
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

}
