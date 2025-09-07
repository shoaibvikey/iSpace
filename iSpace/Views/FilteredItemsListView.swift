//
//  FilteredItemsListView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct FilteredItemsListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let items: [StoredItem]
    let itemType: ItemType

    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: ItemDetailView(item: item, dataService: viewModel.dataService)) {
                    HStack {
                        Image(systemName: item.iconName)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 40)
                        Text(item.name)
                            .font(.headline)
                    }
                }
            }
            // REMOVED: .onDelete and .onMove modifiers are gone
        }
        .listStyle(InsetGroupedListStyle())
        .overlay {
                    if items.isEmpty {
                        EmptyStateView(
                            iconName: "key.horizontal.fill",
                            message: "Your passwords will appear here.\nTap '+' to get started."
                        )
                    }
                }
    }
    
    // REMOVED: The delete and move functions are no longer needed here
}







//#Preview {
//    FilteredItemsListView()
//}
