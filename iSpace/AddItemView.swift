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
                    TextField("Display Name (e.g., 'Google Account')", text: $viewModel.name)
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
            TextField("Card Number", text: $viewModel.cardNumber).keyboardType(.numberPad)
            TextField("Expiry Date (MM/YY)", text: $viewModel.expiry).keyboardType(.numberPad)
            SecureField("CVV", text: $viewModel.cvv).keyboardType(.numberPad)
        }
    }
}


#Preview {
    AddItemView()
}
