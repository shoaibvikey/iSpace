//
//  ContentView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

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


extension String: @retroactive Identifiable {
    public var id: String { self }
}

//#Preview {
//    ContentView()
//}
