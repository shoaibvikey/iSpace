//
//  DocumentsListView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 18/09/25.
//

import SwiftUI

struct DocumentsListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let items: [StoredItem]

    var body: some View {
        Group {
            if items.isEmpty {
                if viewModel.searchText.isEmpty {
                    EmptyStateView(
                        iconName: "doc.on.doc.fill",
                        message: "Your documents will appear here.\nTap '+' to get started."
                    )
                } else {
                    EmptyStateView(
                        iconName: "magnifyingglass",
                        message: "No results found for \"\(viewModel.searchText)\""
                    )
                }
            } else {
                List {
                    ForEach(items) { item in
                        NavigationLink(destination: DocumentDetailView(item: item)) {
                            HStack {
                                Image(systemName: "doc.text.fill")
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
//    DocumentsListView()
//}
