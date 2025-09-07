//
//  Persistence.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import Foundation
import Security


class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.yourapp.securevault"

    private init() {}

    func save(_ data: Data, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func read(for account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { throw KeychainError.readFailed(status) }
        return item as? Data
    }

    func delete(for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    enum KeychainError: Error {
        case saveFailed(OSStatus), readFailed(OSStatus), deleteFailed(OSStatus)
        var localizedDescription: String {
            switch self {
            case .saveFailed(let s): return "Failed to save item. Status: \(s)"
            case .readFailed(let s): return "Failed to read item. Status: \(s)"
            case .deleteFailed(let s): return "Failed to delete item. Status: \(s)"
            }
        }
    }
}

class DataService {
    private let itemsKey = "storedItemsList"

    func loadItemsList() -> [StoredItem] {
        guard let data = UserDefaults.standard.data(forKey: itemsKey),
              let items = try? JSONDecoder().decode([StoredItem].self, from: data) else {
            return []
        }
        return items
    }

    func saveItemsList(_ items: [StoredItem]) {
        if let encodedItems = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedItems, forKey: itemsKey)
        }
    }
    
    func saveData<T: Encodable>(_ data: T, id: String) throws {
        let encodedData = try JSONEncoder().encode(data)
        try KeychainHelper.shared.save(encodedData, for: id)
    }

    func deleteData(for id: String) throws {
        try KeychainHelper.shared.delete(for: id)
    }
    
    func getDecryptedDetails<T: Decodable>(for item: StoredItem) throws -> T? {
        guard let data = try KeychainHelper.shared.read(for: item.id.uuidString) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
