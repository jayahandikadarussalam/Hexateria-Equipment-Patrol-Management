//
//  AuthViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import Foundation
import SwiftUI
import Combine
//import os

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}
//private let logger = Logger(subsystem: "com.yourapp.HexaPatrol", category: "Authentication")


@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = nil         // Store user details
    @Published var plants: [PlantData] = [] // Store plant data
    @Published var loginMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let loginURL = URL(string: "http://127.0.0.1:8000/api/login")!
    private let logoutURL = URL(string: "http://127.0.0.1:8000/api/logout")!
    private let hirarkiURL = URL(string: "http://127.0.0.1:8000/api/hirarki-data")!
    
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
        }
    
    // Function to login and fetch all data
    func login(email: String, password: String) async {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print the raw response body for troubleshooting
            if let responseBody = String(data: data, encoding: .utf8) {
                print("Raw Response Body: \(responseBody)")
            }
            
            // Check HTTP response status
            guard let httpResponse = response as? HTTPURLResponse else {
                loginMessage = "Failed to login. Unknown error occurred."
                print("Error: Response is not HTTPURLResponse")
                return
            }
            
            if httpResponse.statusCode == 200 {
                clearErrorMessage()
                // Decode the JSON response
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                // Populate model data
                self.user = decodedResponse.data.user
//                self.plants = decodedResponse.data.plantData
                self.token = decodedResponse.data.token
                self.isLoggedIn = true
                self.loginMessage = "Login successful. Welcome \(self.user?.name ?? "User")!"
                
                print("Login successful for user: \(self.user?.name ?? "Unknown")")
                print("Token received from server: \(String(decodedResponse.data.token.prefix(10)))...")
                print("Token type: \(decodedResponse.data.tokenType)")
                
                await fetchHirarkiData()
            } else {
                // Decode the error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                    self.loginMessage = "Login failed: \(errorResponse.message)"
                    print("Error from server: \(errorResponse.message)")
                } else {
                    self.errorMessage = "Unknown error occurred."
                    self.loginMessage = "Login failed. Unable to parse error message."
                    print("Error: Unable to decode error response.")
                }
            }
        } catch {
            // Handle decoding or network errors
            print("Error during login: \(error.localizedDescription)")
            loginMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
//    func fetchHirarkiData() async {
//        guard let token = token else { return }
//
//        var request = URLRequest(url: hirarkiURL)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Raw Response Hirarki Data: \(responseBody)")
//            }
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Failed to fetch plant data")
//                return
//            }
//
//            let decodedResponse = try JSONDecoder().decode([HierarchyResponse].self, from: data)
//            DispatchQueue.main.async {
//                self.plants = decodedResponse.data
//            }
//        } catch {
//            print("Error fetching plant data: \(error)")
//        }
//    }
    
    func fetchHirarkiData() async {
        guard let token = token else { return }

        var request = URLRequest(url: hirarkiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to fetch plant data")
                return
            }

            // Decode the data to the correct response type
            let decodedResponse = try JSONDecoder().decode(HierarchyResponse.self, from: data)
            DispatchQueue.main.async {
                self.plants = decodedResponse.data
            }
        } catch {
            print("Error fetching plant data: \(error)")
        }
    }


    
    func logout() {
        guard let token = self.token else {
            print("No token available for logout.")
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
                    print("Error: Response is not HTTPURLResponse")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    // Clear the token and user data
                    self.token = nil
                    self.user = nil
                    self.email = ""
                    self.password = ""
                    UserDefaults.standard.removeObject(forKey: "userToken")
                    UserDefaults.standard.removeObject(forKey: "email")
                    UserDefaults.standard.removeObject(forKey: "password")
                    isLoggedIn = false
                    
                    print("isLoggedIn after logout: \(isLoggedIn)")
                    
                    // Verify token clearing
                    if let storedToken = UserDefaults.standard.string(forKey: "userToken") {
                        print("Warning: Token still exists in UserDefaults: \(String(storedToken.prefix(10)))...")
                    } else {
                        print("Token successfully cleared from UserDefaults")
                    }
                    
                    // Log the result
                    if isLoggedIn == false {
                        print("Logout successful: User is now logged out.")
                    } else {
                        print("Logout failed: User is still logged in.")
                    }
                } else {
                    print("Logout request failed with status code: \(httpResponse.statusCode)")
                }
            } catch {
                print("Error during logout: \(error.localizedDescription)")
            }
        }
    }
    
    
    func clearErrorMessage() {
        self.errorMessage = ""
        self.loginMessage = ""
    }
    
//    func refreshHirarkiData() async {
//        guard self.token != nil else {
//            print("No token available for refresh")
//            return
//        }
//    }
    
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
 
}
