//
//  AuthViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import Foundation
import Combine

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
        loadHirarkiData()
    }

    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        }
        
//        if let plantData = UserDefaults.standard.data(forKey: "plantData"),
//           let decodedPlants = try? JSONDecoder().decode([PlantData].self, from: plantData) {
//            self.plants = decodedPlants
//        }
    }
    
    private func saveUserData() {
        if let user = self.user {
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "userData")
                print("Users data saved successfully. Data: \(user)")
        }
    }
        
//        if !plants.isEmpty {
//            if let encodedPlants = try? JSONEncoder().encode(plants) {
//                UserDefaults.standard.set(encodedPlants, forKey: "plantData")
//            }
//        }
    }
    
//    private func saveHirarkiData() {
//        do {
//            let data = try JSONEncoder().encode(plants)
//            UserDefaults.standard.set(data, forKey: "savedHirarkiData")
//            print("Hirarki data saved successfully. Data: \(plants)")
//        } catch {
//            print("Failed to save hirarki data: \(error)")
//        }
//    }
    
    private func saveHirarkiData() {
        if let data = UserDefaults.standard.data(forKey: "savedHirarkiData") {
            do {
                let savedPlants = try JSONDecoder().decode([PlantData].self, from: data)
                print("Saved plants in UserDefaults: \(savedPlants)")
            } catch {
                print("Failed to decode saved plants: \(error)")
            }
        } else {
            print("No data found in Hirarki UserDefaults.")
        }
    }

//    private func loadHirarkiData() {
//        if let data = UserDefaults.standard.data(forKey: "savedHirarkiData") {
//            do {
//                let loadedPlants = try JSONDecoder().decode([PlantData].self, from: data)
//                self.plants = loadedPlants
//                print("Hirarki data loaded successfully.")
//            } catch {
//                print("Failed to load hirarki data: \(error)")
//            }
//        }
//    }
    
    private func loadHirarkiData() {
        if let data = UserDefaults.standard.data(forKey: "savedHirarkiData") {
            do {
                let loadedPlants = try JSONDecoder().decode([PlantData].self, from: data)
                self.plants = loadedPlants
                print("Hirarki data loaded successfully. Data: \(plants)")
            } catch {
                print("Failed to load hirarki data: \(error)")
            }
        } else {
            print("No saved hirarki data found in UserDefaults.")
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
                saveHirarkiData()
                
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
    func fetchHirarkiData() async {
        guard let token = token else { return }

        var request = URLRequest(url: hirarkiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseBody = String(data: data, encoding: .utf8) {
                print("Raw Response Hirarki: \(responseBody)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return
            }

            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
            DispatchQueue.main.async {
                self.plants = decodedResponse.data
                print("Fetched plants: \(self.plants)") // Verify fetched data
                   if !self.plants.isEmpty {
                       self.saveHirarkiData()
                   } else {
                       print("No data to save. Plants array is empty.")
                   }
            }
            
            // Save plants data after fetching
            saveUserData()
        } catch {
            print("Error fetching plant data: \(error)")
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


    // Clear error messages
    func clearErrorMessage() {
        self.errorMessage = ""
        self.loginMessage = ""
    }
}
