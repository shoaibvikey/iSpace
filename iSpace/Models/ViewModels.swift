//
//  ViewModels.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI
import LocalAuthentication
import Combine

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var passwordDetails: PasswordDetails?
    @Published var cardDetails: CardDetails?
    @Published var alertItem: AlertItem?
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
            alertItem = AlertItem(title: "Error", message: "Failed to decrypt data: \(error.localizedDescription)")
        }
    }

    func confirmDeletion(appViewModel: AppViewModel) {
        appViewModel.deleteItem(withId: item.id)
    }
}

struct DraftItem: Codable {
    var selectedType: ItemType = .password
    var name = ""
    var website = ""
    var username = ""
    var secret = ""
    var cardHolder = ""
    var cardNumber = ""
    var expiry = ""
    var cvv = ""
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
    
    @Published var nameError: String?
    @Published var cardNumberError: String?
    @Published var expiryError: String?
    @Published var cvvError: String?

    static let draftKey = "addItemFormDraft"
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadDraft()
        
        let textFields1 = Publishers.CombineLatest4($name, $website, $username, $secret)
        let textFields2 = Publishers.CombineLatest4($cardHolder, $cardNumber, $expiry, $cvv)
        
        Publishers.CombineLatest(textFields1, textFields2)
            .map { _ in () }
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.validateFields()
                self?.saveDraft()
            }
            .store(in: &cancellables)
            
        $selectedType
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateFields()
                self?.saveDraft()
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
            clearDraft()
        } catch {
            appViewModel.alertItem = AlertItem(title: "Error", message: "Error encoding data: \(error.localizedDescription)")
        }
    }
    
    func cancelAndClearDraft() {
        clearDraft()
    }
    
    private func saveDraft() {
        let draft = DraftItem(selectedType: self.selectedType, name: self.name, website: self.website, username: self.username, secret: self.secret, cardHolder: self.cardHolder, cardNumber: self.cardNumber, expiry: self.expiry, cvv: self.cvv)
        if let data = try? JSONEncoder().encode(draft) {
            // FIXED: Use Self.draftKey to access the static property
            UserDefaults.standard.set(data, forKey: Self.draftKey)
        }
    }

    private func loadDraft() {
        // FIXED: Use Self.draftKey to access the static property
        guard let data = UserDefaults.standard.data(forKey: Self.draftKey),
              let draft = try? JSONDecoder().decode(DraftItem.self, from: data) else { return }
        
        self.selectedType = draft.selectedType
        self.name = draft.name
        self.website = draft.website
        self.username = draft.username
        self.secret = draft.secret
        self.cardHolder = draft.cardHolder
        self.cardNumber = draft.cardNumber
        self.expiry = draft.expiry
        self.cvv = draft.cvv
    }
    
    private func clearDraft() {
        // FIXED: Use Self.draftKey to access the static property
        UserDefaults.standard.removeObject(forKey: Self.draftKey)
    }
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var items: [StoredItem] = []
    @Published var isLocked = true
    @Published var alertItem: AlertItem?
    @Published var searchText = ""
    
    var lastInactiveDate: Date?
    let dataService = DataService()

    init() {
        UserDefaults.standard.removeObject(forKey: AddItemViewModel.draftKey)
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
    
    var filteredPasswordItems: [StoredItem] {
        let allPasswords = items.filter { $0.type == .password }
        if searchText.isEmpty {
            return allPasswords
        } else {
            return allPasswords.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
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
                        self.alertItem = AlertItem(title: "Error", message: "Authentication failed.")
                    }
                }
            }
        } else {
            self.alertItem = AlertItem(title: "Error", message: "Biometrics not available.")
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
                 alertItem = AlertItem(title: "Error", message: "Failed to delete item: \(error.localizedDescription)")
            }
        }
    }
}



