//
//  CantPatrolRequest.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 04/02/25.
//

import Foundation

struct CantPatrolResponse: Codable {
    let message: String
    let data: CantPatrolData
}

struct CantPatrolData: Codable {
    let user: UserResponse
    let photo: PhotoResponse
    let reasonTransactions: ReasonTransactionsResponse

    enum CodingKeys: String, CodingKey {
        case user, photo
        case reasonTransactions = "reason_transactions"
    }
}

struct UserResponse: Codable {
    let id: Int
    let name, username, department, role: String
    let date, status, updatedAt, createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, department, role, date, status
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}

struct PhotoResponse: Codable {
    let id, userId: Int
    let imageName: String
    let size: String
    let updatedAt, createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case imageName = "image_name"
        case size, updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}

struct ReasonTransactionsResponse: Codable {
    let id, userId: Int
    let status, reason, location, lon, lat, date, updatedAt, createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status, reason, location, lon, lat, date
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}
