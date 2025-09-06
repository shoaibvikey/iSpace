//
//  HelperViews.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

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
