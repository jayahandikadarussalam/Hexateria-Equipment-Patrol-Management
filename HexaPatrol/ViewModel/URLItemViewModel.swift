import Foundation

class URLItemViewModel: ObservableObject {
    @Published var predefinedURLs: [URLItem] = []
    @Published var selectedURL: String = BaseURL.url.absoluteString
    
    init() {
        loadURLs()
    }
    
    // MARK: - CRUD Operations
    
    func addURL(name: String, url: String) -> Bool {
        guard !name.isEmpty, !url.isEmpty else { return false }
        guard let _ = URL(string: url) else { return false }
        
        let newItem = URLItem(name: name, url: url)
        predefinedURLs.append(newItem)
        saveURLs()
        return true
    }
    
    func deleteURL(at offsets: IndexSet) {
        predefinedURLs.remove(atOffsets: offsets)
        saveURLs()
    }
    
    func updateSelectedURL(_ url: String) -> Bool {
        guard let _ = URL(string: url) else { return false }
        selectedURL = url
        UserDefaults.standard.set(url, forKey: "BaseURL")
        return true
    }
    
    // MARK: - Data Persistence
    
    private func loadURLs() {
        // Load default URLs if no saved URLs exist
        if let savedURLs = UserDefaults.standard.data(forKey: "PredefinedURLs"),
           let decodedURLs = try? JSONDecoder().decode([URLItem].self, from: savedURLs) {
            predefinedURLs = decodedURLs
        } else {
            // Default URLs
            predefinedURLs = [
                URLItem(name: "Default", url: "http://192.168.18.96:8000/api/"),
                URLItem(name: "Hexateria", url: "http://192.168.18.87:8000/api/"),
                URLItem(name: "Hexateria 5G", url: "http://192.168.18.88:8000/api/"),
                URLItem(name: "Office APWG2", url: "http://192.168.18.31:8000/api/"),
                URLItem(name: "Office HOME56", url: "http://192.168.1.37:8000/api/")
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