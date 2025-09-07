//
//  HelperViews.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.secondary.opacity(0.7))

            Text(message)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        // This ensures the view takes up the whole space and fixes text wrapping
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Match the background color of the list style
        .background(Color(.systemGroupedBackground))
    }
}

// These small, reusable views are kept in their own file for organization.

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value)
        }.padding(.vertical, 4)
    }
}

struct SecretInfoRow: View {
    let label: String
    let value: String
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundColor(.secondary)
            HStack {
                if isRevealed { Text(value) }
                else { Text(String(repeating: "•", count: value.count)) }
                Spacer()
                Button(action: { isRevealed.toggle() }) {
                    Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }
        }.padding(.vertical, 4)
    }
}

//#Preview {
//    HelperViews()
//}
