//
//  ContentView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

// This view acts as a router, showing the lock screen or the main list.
struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.isLocked {
                LockScreenView()
            } else {
                MainTabView()
            }
        }
        .alert(item: $viewModel.alertMessage) { message in
            Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
}

// This extension allows us to use a String directly with the .alert modifier.
extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    ContentView()
}
