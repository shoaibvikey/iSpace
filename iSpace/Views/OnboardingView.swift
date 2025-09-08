//
//  OnboardingView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 08/09/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            TabView {
                OnboardingPageView(
                    imageName: "shield.lefthalf.filled",
                    
                    title: "Welcome to iSpace",
                    description: "Your personal and secure offline vault for cards and passwords."
                )
                
                OnboardingPageView(
                    imageName: "lock.icloud.fill",
                    title: "Offline & Secure",
                    description: "Your data is encrypted and stored only on your device's secure Keychain. Nothing is ever uploaded to the cloud."
                )
                
                OnboardingPageView(
                    imageName: "faceid",
                    title: "Biometric Lock",
                    description: "Enable Face ID or Passcode to ensure only you can access your vault.",
                    isLastPage: true
                )
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

struct OnboardingPageView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    let imageName: String
    let title: String
    let description: String
    var isLastPage: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.accent)
                .padding(.bottom, 20)

            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(description)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if isLastPage {
                Button(action: {
                    viewModel.completeOnboarding()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 40)
            }
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    OnboardingView()
}
