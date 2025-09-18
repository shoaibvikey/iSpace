//
//  FileHelper.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 18/09/25.
//

import Foundation
import CryptoKit

// This new service handles encrypting/decrypting and saving/loading files.
class FileHelper {
    static let shared = FileHelper()
    private let key: SymmetricKey

    private init() {
        // For a real app, you would securely generate and store this key in the Keychain.
        // For simplicity, we are deriving it from a hardcoded string.
        let keyData = "a-very-secret-key-for-files".data(using: .utf8)!
        self.key = SymmetricKey(data: SHA256.hash(data: keyData))
    }

    func save(data: Data, with fileName: String) throws {
        let encryptedData = try AES.GCM.seal(data, using: key).combined
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        try encryptedData?.write(to: url)
    }

    func read(from fileName: String) throws -> Data? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        let encryptedData = try Data(contentsOf: url)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func delete(from fileName: String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
