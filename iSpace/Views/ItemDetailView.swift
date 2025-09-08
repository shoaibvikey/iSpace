//
//  ItemDetailView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: ItemDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    let item: StoredItem
    
    init(item: StoredItem, dataService: DataService) {
        self.item = item
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item, dataService: dataService))
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                if let details = viewModel.passwordDetails {
                    WebsiteRow(label: "Website", value: details.website)
                    CopyableInfoRow(label: "Username", value: details.username)
                    CopyableInfoRow(label: "Password", value: details.secret, isSecret: true)
                }
                
                if let details = viewModel.cardDetails {
                    InfoRow(label: "Card Holder Name", value: details.cardHolderName)
                    CopyableInfoRow(label: "Card Number", value: details.cardNumber, isSecret: true)
                    InfoRow(label: "Expiry", value: details.expiryDate)
                    CopyableInfoRow(label: "CVV", value: details.cvv, isSecret: true)
                    
                   
                }
            }
            
            Section {
                Button(role: .destructive) {
                    viewModel.showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .foregroundStyle(Color.red)
            
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.loadDetails)
        .alert("Are you sure?", isPresented: $viewModel.showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.confirmDeletion(appViewModel: appViewModel)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}



//#Preview {
//    ItemDetailView()
//}
