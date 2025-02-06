//
//  CantPatrolRequest.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 04/02/25.
//


// MARK: - Models
struct CantPatrolRequest: Codable {
    let user: UserRequest
    let photo: PhotoRequest
    let reasonTransactions: ReasonTransactionsRequest
    
    enum CodingKeys: String, CodingKey {
        case user
        case photo
        case reasonTransactions = "reason_transactions"
    }
}

struct UserRequest: Codable {
    let username: String
    let department: String
    let role: String
    let date: String
}

struct PhotoRequest: Codable {
    let imageName: String
    let imagePath: String
    let mimeType: String
    let size: String
    
    enum CodingKeys: String, CodingKey {
        case imageName = "image_name"
        case imagePath = "image_path"
        case mimeType = "mime_type"
        case size
    }
}

struct ReasonTransactionsRequest: Codable {
    let status: String
    let reason: String
    let location: String
    let date: String
}

// MARK: - Response Model
struct CantPatrolResponse: Codable {
    let message: String
    let data: CantPatrolRequest
}