//
//  LockScreenView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Vault Locked")
                .font(.largeTitle.bold())
            
            Button(action: {
                viewModel.authenticate()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock Now")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            viewModel.authenticate()
        }
    }
}


#Preview {
    LockScreenView()
}
