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
            // Cards Tab
            NavigationStack {
                CardDeckView(items: viewModel.cardItems)
                    .navigationTitle("My Cards")
                    .toolbar { toolbarContent }
            }
            .tabItem {
                Label("Cards", systemImage: "creditcard.fill")
            }

            // Passwords Tab
            NavigationStack {
                FilteredItemsListView(items: viewModel.passwordItems, itemType: .password)
                    .navigationTitle("My Passwords")
                    .toolbar { toolbarContent }
            }
            .tabItem {
                Label("Passwords", systemImage: "key.fill")
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView()
        }
    }
    
    // REVERTED: The toolbar is back to its original state
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
