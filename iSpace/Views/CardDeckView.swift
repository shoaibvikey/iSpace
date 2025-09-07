//
//  CardDeckView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct CardDeckView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let items: [StoredItem]

    var body: some View {
        if items.isEmpty {
            EmptyStateView(
                iconName: "creditcard.and.123",
                message: "Your cards will appear here.\nTap '+' to get started."
            )
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: ItemDetailView(item: item, dataService: viewModel.dataService)) {
                            CardListItemView(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

struct CardListItemView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let item: StoredItem
    
    @State private var cardDetails: CardDetails?

    var body: some View {
        Group {
            if let details = cardDetails {
                CreditCardView(item: item, details: details)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1.586, contentMode: .fit)
                    .overlay(Text(item.name).foregroundColor(.secondary))
            }
        }
        .onAppear(perform: loadCardDetails)
    }
    
    private func loadCardDetails() {
        Task {
            do {
                self.cardDetails = try viewModel.dataService.getDecryptedDetails(for: item)
            } catch {
                print("Failed to load card details for list item: \(error)")
            }
        }
    }
}







//#Preview {
//    CardDeckView()
//}
