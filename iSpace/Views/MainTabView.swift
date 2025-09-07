//
//  MainTabView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddItemSheet = false

    var body: some View {
        TabView {
            NavigationStack {
                CardDeckView(items: viewModel.filteredCardItems)
                    .navigationTitle("My Cards")
                    .toolbar { toolbarContent }
            }
            .tabItem {
                Label("Cards", systemImage: "creditcard.fill")
            }

            NavigationStack {
                FilteredItemsListView(items: viewModel.filteredPasswordItems, itemType: .password)
                    .navigationTitle("My Passwords")
                    .toolbar { toolbarContent }
            }
            .tabItem {
                Label("Passwords", systemImage: "key.fill")
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search Card or Password")
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddItemSheet = true }) { Image(systemName: "plus") }
        }
    }
}






//#Preview {
//    MainTabView()
//}
