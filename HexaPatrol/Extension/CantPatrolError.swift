//
//  CantPatrolError.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/02/25.
//


import Foundation

enum CantPatrolError: LocalizedError {
    case unauthorized
    case validation(String)
    case networkError(Int)
    case invalidResponse
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Authentication required"
        case .validation(let message): return message
        case .networkError(let code): return "Server error: \(code)"
        case .invalidResponse: return "Invalid server response"
        case .encodingError: return "Failed to encode request"
        }
    }
}