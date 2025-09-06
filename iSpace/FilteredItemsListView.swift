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
            .onDelete(perform: delete)
        }
        .listStyle(InsetGroupedListStyle())
        .overlay {
            if items.isEmpty {
                let typeName = (itemType == .card) ? "cards" : "passwords"
                Text("No \(typeName) yet.\nTap '+' to add one.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // This function finds the correct item in the main 'items' array to delete.
    private func delete(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { items[$0] }
        let indicesInMainArray = itemsToDelete.compactMap { itemToDelete in
            viewModel.items.firstIndex(where: { $0.id == itemToDelete.id })
        }
        
        guard !indicesInMainArray.isEmpty else { return }
        
        viewModel.deleteItem(at: IndexSet(indicesInMainArray))
    }
}


//#Preview {
//    FilteredItemsListView()
//}
