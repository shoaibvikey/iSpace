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
        // UPDATED: Using a Group with an if/else is more reliable
        // than a ZStack for maintaining the navigation title.
        Group {
            if items.isEmpty {
                // If there are no items, we show the empty state directly.
                // This view will now properly anchor the navigation title.
                if viewModel.searchText.isEmpty {
                    EmptyStateView(
                        iconName: "lock.slash",
                        message: "Your passwords will appear here.\nTap '+' to get started."
                    )
                } else {
                    EmptyStateView(
                        iconName: "magnifyingglass",
                        message: "No results found for \"\(viewModel.searchText)\""
                    )
                }
            } else {
                // If there are items, we show the list as before.
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
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
}






//#Preview {
//    FilteredItemsListView()
//}
