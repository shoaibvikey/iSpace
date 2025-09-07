//
//  ViewModels.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI
import LocalAuthentication
import Combine

// ViewModel for the ItemDetailView
@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var passwordDetails: PasswordDetails?
    @Published var cardDetails: CardDetails?
    @Published var alertMessage: String?
    @Published var showDeleteAlert = false

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

    func confirmDeletion(appViewModel: AppViewModel) {
        appViewModel.deleteItem(withId: item.id)
    }
}

// ViewModel for the AddItemView
@MainActor
class AddItemViewModel: ObservableObject {
    // Form fields
    @Published var selectedType: ItemType = .password
    @Published var name = ""
    @Published var website = ""
    @Published var username = ""
    @Published var secret = ""
    @Published var cardHolder = ""
    @Published var cardNumber = ""
    @Published var expiry = ""
    @Published var cvv = ""
    
    // Validation error messages
    @Published var nameError: String?
    @Published var cardNumberError: String?
    @Published var expiryError: String?
    @Published var cvvError: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // FIXED: Broke the single large publisher into two smaller, nested ones.
        let textFields1 = Publishers.CombineLatest4($name, $website, $username, $secret)
        let textFields2 = Publishers.CombineLatest4($cardHolder, $cardNumber, $expiry, $cvv)
        
        Publishers.CombineLatest(textFields1, textFields2)
            .map { _ in () }
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.validateFields()
            }
            .store(in: &cancellables)
            
        $selectedType
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateFields()
            }
            .store(in: &cancellables)
    }

    var isFormValid: Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        
        switch selectedType {
        case .password:
            return !website.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !username.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !secret.trimmingCharacters(in: .whitespaces).isEmpty
        case .card:
            if cardHolder.trimmingCharacters(in: .whitespaces).isEmpty { return false }
            if cardNumber.filter({ $0.isNumber }).count != 16 { return false }
            if cvv.filter({ $0.isNumber }).count < 3 { return false }
            
            let components = expiry.split(separator: "/")
            if components.count == 2, let month = Int(components[0]), let year = Int(components[1]), (1...12).contains(month) {
                let currentYear = Calendar.current.component(.year, from: Date()) % 100
                let currentMonth = Calendar.current.component(.month, from: Date())
                if year < currentYear || (year == currentYear && month < currentMonth) {
                    return false
                }
            } else { return false }
            
            return true
        }
    }

    private func validateFields() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Display Name cannot be empty." : nil
        
        if selectedType == .card {
            cardNumberError = (cardNumber.filter({ $0.isNumber }).count != 16 && !cardNumber.isEmpty) ? "Card number must be 16 digits." : nil
            cvvError = (cvv.filter({ $0.isNumber }).count < 3 && !cvv.isEmpty) ? "CVV must be 3 or 4 digits." : nil
            
            if !expiry.isEmpty {
                let components = expiry.split(separator: "/")
                if components.count == 2, let month = Int(components[0]), let year = Int(components[1]), (1...12).contains(month) {
                    let currentYear = Calendar.current.component(.year, from: Date()) % 100
                    let currentMonth = Calendar.current.component(.month, from: Date())
                    expiryError = (year < currentYear || (year == currentYear && month < currentMonth)) ? "Card has expired." : nil
                } else {
                    expiryError = "Use MM/YY format."
                }
            } else {
                expiryError = nil
            }
        } else {
            cardNumberError = nil
            expiryError = nil
            cvvError = nil
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

// Main AppViewModel
@MainActor
class AppViewModel: ObservableObject {
    @Published var items: [StoredItem] = []
    @Published var isLocked = true
    @Published var alertMessage: String?
    @Published var searchText = ""
    
    let dataService = DataService()

    init() {
        fetchItems()
    }
    
    var filteredCardItems: [StoredItem] {
            let allCards = items.filter { $0.type == .card }
            if searchText.isEmpty {
                return allCards
            } else {
                return allCards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // UPDATED: This property now filters passwords based on the searchText
    var filteredPasswordItems: [StoredItem] {
            let allPasswords = items.filter { $0.type == .password }
            if searchText.isEmpty {
                return allPasswords
            } else {
                return allPasswords.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
    
    var cardItems: [StoredItem] {
        items.filter { $0.type == .card }
    }
    
    var passwordItems: [StoredItem] {
        items.filter { $0.type == .password }
    }
    
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
    
    func fetchItems() {
        self.items = dataService.loadItemsList()
    }
    
    func addItem(_ item: StoredItem) {
        items.append(item)
        dataService.saveItemsList(items)
    }
    
    func addData<T: Encodable>(_ data: T, id: String) throws {
        try dataService.saveData(data, id: id)
    }
    
    func deleteItem(withId id: UUID) {
        if let itemToDelete = items.first(where: { $0.id == id }) {
            do {
                try dataService.deleteData(for: itemToDelete.id.uuidString)
                items.removeAll { $0.id == id }
                dataService.saveItemsList(items)
            } catch {
                 alertMessage = "Failed to delete item: \(error.localizedDescription)"
            }
        }
    }
}

