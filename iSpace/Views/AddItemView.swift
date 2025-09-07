//
//  AddItemView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct AddItemView: View {
    @StateObject private var viewModel = AddItemViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    ValidatedField(
                        title: "Display Name (e.g., 'Google Account')",
                        text: $viewModel.name,
                        error: viewModel.nameError
                    )
                    Picker("Item Type", selection: $viewModel.selectedType) {
                        Text("Password").tag(ItemType.password)
                        Text("Credit Card").tag(ItemType.card)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                switch viewModel.selectedType {
                case .password: passwordSection
                case .card: cardSection
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveItem(appViewModel: appViewModel)
                        dismiss()
                    }.disabled(!viewModel.isFormValid)
                }
            }
        }
    }
    
    private var passwordSection: some View {
        Section(header: Text("Password Details")) {
            TextField("Website (e.g., 'google.com')", text: $viewModel.website).keyboardType(.URL).autocapitalization(.none)
            TextField("Username or Email", text: $viewModel.username).autocapitalization(.none)
            SecureField("Password", text: $viewModel.secret)
        }
    }
    
    private var cardSection: some View {
        Section(header: Text("Card Details")) {
            TextField("Name on Card", text: $viewModel.cardHolder)
            
            ValidatedField(
                title: "Card Number",
                text: $viewModel.cardNumber,
                error: viewModel.cardNumberError
            )
            .keyboardType(.numberPad)
            .onChange(of: viewModel.cardNumber) { _, newValue in
                formatCardNumber(newValue: newValue)
            }
            
            HStack {
                ValidatedField(
                    title: "Expiry (MM/YY)",
                    text: $viewModel.expiry,
                    error: viewModel.expiryError
                )
                .keyboardType(.numberPad)
                .onChange(of: viewModel.expiry) { _, newValue in
                    formatExpiryDate(newValue: newValue)
                }
                
                ValidatedField(
                    title: "CVV",
                    text: $viewModel.cvv,
                    error: viewModel.cvvError
                )
                .keyboardType(.numberPad)
                .onChange(of: viewModel.cvv) { _, newValue in
                    viewModel.cvv = String(newValue.prefix(4))
                }
            }
        }
    }
    
    private func formatCardNumber(newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        var result = ""
        let limit = 16
        
        for (index, digit) in filtered.prefix(limit).enumerated() {
            if index != 0 && index % 4 == 0 {
                result.append(" ")
            }
            result.append(digit)
        }
        viewModel.cardNumber = result
    }
    
    private func formatExpiryDate(newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        var result = ""
        let limit = 4
        
        for (index, digit) in filtered.prefix(limit).enumerated() {
            if index == 2 {
                result.append("/")
            }
            result.append(digit)
        }
        viewModel.expiry = result
    }
}

struct ValidatedField: View {
    let title: String
    @Binding var text: String
    let error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.bottom, error == nil ? 0 : 8)
    }
}





//#Preview {
//    AddItemView()
//}
