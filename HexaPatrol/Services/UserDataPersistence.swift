import Foundation

class UserDataPersistence {
    static let shared = UserDataPersistence()

    private init() {}

    // MARK: - Save user data to persistence
    func saveUserData(_ user: User) {
        // Logic to save user data (e.g., UserDefaults, CoreData, or local file)
    }

    // MARK: - Load user data from persistence
    func loadUserData() -> User? {
        // Logic to load user data
        return nil
    }
}