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
        if viewModel.showOnboarding {
                    OnboardingView()
        } else {
            Group {
                if viewModel.isLocked {
                    LockScreenView()
                } else {
                    MainTabView()
                }
            }
            // FIXED: Updated to use the new 'alertItem' property
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// REMOVED: The old String extension that was causing the second error.

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel())
    }
}



//#Preview {
//    ContentView()
//}
