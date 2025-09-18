//
//  Models.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import Foundation

struct StoredItem: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: ItemType

    var iconName: String {
        switch type {
        case .card:
            return "creditcard.fill"
        case .password:
            return "key.fill"
        case .document:
            return "filetext.fill"
        }
    }
}

enum ItemType: String, Codable {
    case card
    case password
    case document
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

struct DocumentDetails: Codable, Hashable {
    let fileName: String
    let documentType: DocumentType
}

// NEW: An enum to differentiate between document types.
enum DocumentType: String, Codable {
    case pdf
    case image
}

