//
//  iSpaceApp.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

@main
struct iSpaceApp: App {
    @StateObject private var viewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.accent
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .tint(.accent)
        }
        // FIXED: Updated to the modern, single-parameter syntax to remove the warning.
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                viewModel.lastInactiveDate = Date()
            } else if newPhase == .active {
                guard let lastInactive = viewModel.lastInactiveDate else { return }
                let gracePeriod: TimeInterval = 5
              
                if Date().timeIntervalSince(lastInactive) > gracePeriod {
                    viewModel.lock()
                }
            }
        }
    }
}

