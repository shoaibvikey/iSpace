//
//  Models.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import Foundation

// MARK: - 1. Models
// This file contains all the data structures (the "Model" layer) for the app.

struct StoredItem: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: ItemType
    
    // A helper to show a system image based on the item type
    var iconName: String {
        switch type {
        case .card:
            return "creditcard.fill"
        case .password:
            return "key.fill"
        }
    }
}

enum ItemType: String, Codable {
    case card
    case password
}

struct CardDetails: Codable, Hashable {
    var cardHolderName: String
    var cardNumber: String
    var expiryDate: String
    var cvv: String
}

struct PasswordDetails: Codable, Hashable {
    var website: String
    var username: String
    var secret: String
}
