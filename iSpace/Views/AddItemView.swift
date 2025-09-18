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
                        title: "Display Name (e.g., 'Passport')",
                        text: $viewModel.name,
                        error: viewModel.nameError
                    )
                    Picker("Item Type", selection: $viewModel.selectedType) {
                        Text("Password").tag(ItemType.password)
                        Text("Card").tag(ItemType.card)
                        Text("Document").tag(ItemType.document)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // FIXED: Added the missing case for .document
                switch viewModel.selectedType {
                case .password: passwordSection
                case .card: cardSection
                case .document: documentSection
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.cancelAndClearDraft()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveItem(appViewModel: appViewModel)
                        dismiss()
                    }.disabled(!viewModel.isFormValid)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker(selectedImageData: $viewModel.documentData)
        }
        .sheet(isPresented: $viewModel.showCameraPicker) {
            CameraPicker(selectedImageData: $viewModel.documentData)
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPicker(selectedFileData: $viewModel.documentData)
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
                    title: "Expiry Date (MM/YY)",
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
    
    private var documentSection: some View {
        Section(header: Text("Source")) {
            Button(action: {
                viewModel.documentType = .pdf
                viewModel.showDocumentPicker = true
            }) {
                Label("Import PDF", systemImage: "doc.text.fill")
            }
            
            Button(action: {
                viewModel.documentType = .image
                viewModel.showCameraPicker = true
            }) {
                Label("Take Photo", systemImage: "camera.fill")
            }
            
            Button(action: {
                viewModel.documentType = .image
                viewModel.showPhotoPicker = true
            }) {
                Label("Choose from Library", systemImage: "photo.fill")
            }
            
            if let data = viewModel.documentData {
                HStack {
                    Label("File Selected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(data.count / 1024) KB")
                        .foregroundColor(.secondary)
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
