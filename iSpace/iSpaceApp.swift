//
//  iSpaceApp.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

// MARK: - Main App Entry
@main
struct iSpaceApp: App {
    // 1. Create the ViewModel as a @StateObject here.
    @StateObject private var viewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Inject the ViewModel into the environment for ContentView and all its children.
                .environmentObject(viewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Lock the app when it goes to the background
            if newPhase == .inactive || newPhase == .background {
                viewModel.lock()
            }
        }
    }
}
