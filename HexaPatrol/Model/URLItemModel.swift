//
//  URLItem.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 11/02/25.
//

import Foundation

// Model for URL items
struct URLItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let url: String
    
    init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
}
