//
//  ItemsListView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct ItemsListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddItemSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
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
                .onDelete(perform: viewModel.deleteItem)
            }
            .navigationTitle("My Vault")
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.lock) { Image(systemName: "lock.fill") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItemSheet = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddItemSheet) {
                AddItemView()
            }
            .overlay {
                if viewModel.items.isEmpty {
                    Text("No items yet.\nTap '+' to add one.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}


#Preview {
    ItemsListView()
}
