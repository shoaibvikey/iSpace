//
//  ViewModels.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import Foundation
import LocalAuthentication

// MARK: - 3. ViewModels
// This file contains the logic and state management for each view.

@MainActor
class AppViewModel: ObservableObject {
    @Published var items: [StoredItem] = []
    @Published var isLocked = true
    @Published var alertMessage: String?
    
    let dataService = DataService()

    // NEW: Computed properties to filter items for the tabs
    var cardItems: [StoredItem] {
        items.filter { $0.type == .card }
    }

    var passwordItems: [StoredItem] {
        items.filter { $0.type == .password }
    }

    init() {
        fetchItems()
    }
    
    // --- Authentication ---
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Please authenticate to unlock your vault."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                Task { @MainActor in
                    if success {
                        self.isLocked = false
                    } else {
                        self.alertMessage = "Authentication failed."
                    }
                }
            }
        } else {
            self.alertMessage = "Biometrics not available. Please enable Face ID/Touch ID or a passcode in your device settings."
        }
    }

    func lock() {
        isLocked = true
    }
    
    // --- Data Management ---
    func fetchItems() {
        self.items = dataService.loadItemsList()
    }
    
    func addItem(_ item: StoredItem) {
        items.append(item)
        // Sort items to keep them grouped by type
        items.sort { $0.type.rawValue > $1.type.rawValue }
        dataService.saveItemsList(items)
    }
    
    func addData<T: Encodable>(_ data: T, id: String) throws {
        try dataService.saveData(data, id: id)
    }
    
    func deleteItem(at offsets: IndexSet) {
        // This method works on the main 'items' array.
        // The view will provide the correct indices from the main source of truth.
        items.remove(atOffsets: offsets)
        dataService.saveItemsList(items)
    }
}


@MainActor
class AddItemViewModel: ObservableObject {
    @Published var selectedType: ItemType = .password
    @Published var name = ""
    @Published var website = ""
    @Published var username = ""
    @Published var secret = ""
    @Published var cardHolder = ""
    @Published var cardNumber = ""
    @Published var expiry = ""
    @Published var cvv = ""

    var isFormValid: Bool {
        if name.isEmpty { return false }
        switch selectedType {
        case .password:
            return !website.isEmpty && !username.isEmpty && !secret.isEmpty
        case .card:
            return !cardHolder.isEmpty && !cardNumber.isEmpty && !expiry.isEmpty && !cvv.isEmpty
        }
    }
    
    func saveItem(appViewModel: AppViewModel) {
        let newItemId = UUID()
        let newItem: StoredItem
        
        do {
            switch selectedType {
            case .password:
                let details = PasswordDetails(website: website, username: username, secret: secret)
                try appViewModel.addData(details, id: newItemId.uuidString)
                newItem = StoredItem(id: newItemId, name: name, type: selectedType)
            case .card:
                let details = CardDetails(cardHolderName: cardHolder, cardNumber: cardNumber, expiryDate: expiry, cvv: cvv)
                try appViewModel.addData(details, id: newItemId.uuidString)
                newItem = StoredItem(id: newItemId, name: name, type: selectedType)
            }
            appViewModel.addItem(newItem)
        } catch {
            appViewModel.alertMessage = "Error encoding data: \(error.localizedDescription)"
        }
    }
}


@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var passwordDetails: PasswordDetails?
    @Published var cardDetails: CardDetails?
    @Published var alertMessage: String?

    private let item: StoredItem
    private let dataService: DataService

    init(item: StoredItem, dataService: DataService) {
        self.item = item
        self.dataService = dataService
    }
    
    func loadDetails() {
        do {
            switch item.type {
            case .password:
                self.passwordDetails = try dataService.getDecryptedDetails(for: item)
            case .card:
                self.cardDetails = try dataService.getDecryptedDetails(for: item)
            }
        } catch {
            alertMessage = "Failed to decrypt data: \(error.localizedDescription)"
        }
    }
}

