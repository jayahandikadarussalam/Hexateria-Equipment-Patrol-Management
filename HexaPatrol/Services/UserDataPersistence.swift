//
//  UserDataPersistence.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 09/01/25.
//


import Foundation
import CoreData

class UserDataPersistence {
    static let shared = UserDataPersistence()
    public let context = PersistenceController.shared.container.viewContext
    var user: User?
    private init() {}

//    // MARK: - Save user DataPersistance
//    func saveUserData() {
//        if let user = self.user {
//            if let encodedUser = try? JSONEncoder().encode(user) {
//                UserDefaults.standard.set(encodedUser, forKey: "userData")
//                UserDefaults.standard.synchronize()
//                print("Users data saved successfully. Data: \(user)")
//            }
//        }
//    }
//    
//    // MARK: - Load user DataPersistance
//    func loadUserData() {
//        if let userData = UserDefaults.standard.data(forKey: "userData"),
//           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
//            self.user = decodedUser
//        }
//    }
}
