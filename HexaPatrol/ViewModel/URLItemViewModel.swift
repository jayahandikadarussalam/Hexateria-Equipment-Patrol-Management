//
//  URLItemViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 11/02/25.
//


import Foundation
import Combine
import SwiftUI

class URLItemViewModel: ObservableObject {
    @AppStorage("BaseURL") private var storedURL: String?
    @Published var predefinedURLs: [URLItemModel] = []
    @Published var selectedURL: String = BaseURL.url.absoluteString
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedURL = UserDefaults.standard.string(forKey: "BaseURL") ?? BaseURL.url.absoluteString
        loadURLs()
        
        NotificationCenter.default.publisher(for: .baseURLUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let newURL = BaseURL.url.absoluteString
                print("🔄 Notification received: Updating selectedURL to \(newURL)")
                self.selectedURL = newURL
                self.storedURL = newURL
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - URL Validation
    
    private func isValidAPIURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        
        // Check if URL ends with /api/
        if !urlString.hasSuffix("/api/") {
            return false
        }
        
        // Validate URL components
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        // Must have a host
        guard let host = components.host else {
            return false
        }
        
        // Must use http or https
        guard let scheme = components.scheme,
              (scheme == "http" || scheme == "https") else {
            return false
        }
        
        // Check if it's an IP address or localhost
        let isIPAddress = host.split(separator: ".").count == 4 &&
                         host.split(separator: ".").allSatisfy { $0.allSatisfy { $0.isNumber } }
        let isLocalhost = host == "localhost" || host == "127.0.0.1"
        
        return isIPAddress || isLocalhost
    }
    
    // MARK: - CRUD Operations
    
    func addURL(name: String, url: String) -> Bool {
        guard !name.isEmpty else { return false }
        
        // Validate URL format
        guard isValidAPIURL(url) else { return false }
        
        // Check if name or URL already exists
        if predefinedURLs.contains(where: { $0.name == name || $0.url == url }) {
            print("❌ URL atau nama sudah ada dalam daftar.")
            return false
        }
        
        let newItem = URLItemModel(name: name, url: url)
        predefinedURLs.append(newItem)
        saveURLs()
        return true
    }
    
    func deleteURL(at offsets: IndexSet) {
        predefinedURLs.remove(atOffsets: offsets)
        saveURLs()
    }
    
    func updateSelectedURL(_ url: String) -> Bool {
        print("📝 Starting URL update process for: \(url)")
        
        guard isValidAPIURL(url) else {
            print("❌ Invalid URL format: \(url)")
            return false
        }
        
        guard let newURL = URL(string: url) else {
            print("❌ Could not create URL object")
            return false
        }
        
        // Update storage and cache
        BaseURL.forceUpdateURL(newURL)
        
        // Update view model
        DispatchQueue.main.async { [weak self] in
            self?.selectedURL = url
            self?.storedURL = url
            print("✅ ViewModel and storage updated to: \(url)")
        }
        
        // Verify updates
        print("🔍 Verification:")
        print("BaseURL: \(BaseURL.url.absoluteString)")
        print("Stored URL: \(storedURL ?? "nil")")
        print("Selected URL: \(selectedURL)")
        
        return true
    }
    
    func updateURL(at index: Int, name: String, url: String) -> Bool {
        guard index >= 0, index < predefinedURLs.count else { return false }
        guard isValidAPIURL(url) else { return false }

        predefinedURLs[index] = URLItemModel(name: name, url: url)
        saveURLs()
        return true
    }

    // MARK: - Data Persistence
    
    private func loadURLs() {
        if let savedURLs = UserDefaults.standard.data(forKey: "PredefinedURLs"),
           let decodedURLs = try? JSONDecoder().decode([URLItemModel].self, from: savedURLs) {
            // Validate all saved URLs
            predefinedURLs = decodedURLs.filter { isValidAPIURL($0.url) }
        } else {
            // Default URLs
            predefinedURLs = [
                URLItemModel(name: "Default", url: "http://192.168.18.00:8000/api/"),
                URLItemModel(name: "Hexateria", url: "http://192.168.18.98:8000/api/"),
                URLItemModel(name: "Hexateria 5G", url: "http://192.168.18.96:8000/api/"),
                URLItemModel(name: "Office APWG2", url: "http://192.168.18.31:8000/api/"),
                URLItemModel(name: "Office HOME56", url: "http://192.168.1.37:8000/api/")
            ]
            saveURLs()
        }
    }
    
    private func saveURLs() {
        if let encoded = try? JSONEncoder().encode(predefinedURLs) {
            UserDefaults.standard.set(encoded, forKey: "PredefinedURLs")
        }
    }
}
