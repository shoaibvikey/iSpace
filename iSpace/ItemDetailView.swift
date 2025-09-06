//
//  ItemDetailView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    
    // The view is initialized with the data it needs to create its ViewModel.
    init(item: StoredItem, dataService: DataService) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item, dataService: dataService))
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                if let details = viewModel.passwordDetails {
                    InfoRow(label: "Website", value: details.website)
                    InfoRow(label: "Username", value: details.username)
                    SecretInfoRow(label: "Password", value: details.secret)
                }
                
                if let details = viewModel.cardDetails {
                    InfoRow(label: "Card Holder", value: details.cardHolderName)
                    SecretInfoRow(label: "Card Number", value: details.cardNumber)
                    InfoRow(label: "Expiry", value: details.expiryDate)
                    SecretInfoRow(label: "CVV", value: details.cvv)
                }
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.loadDetails)
        .alert(item: $viewModel.alertMessage) { message in
            Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
}


//#Preview {
//    ItemDetailView()
//}
