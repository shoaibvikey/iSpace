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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}


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

struct CopyableInfoRow: View {
    let label: String
    let value: String
    var isSecret: Bool = false
    
    @State private var didCopy = false
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                // Display logic for secret vs. plain text
                if isSecret && !isRevealed {
                    Text(String(repeating: "•", count: value.count))
                } else {
                    Text(value)
                }
                
                Spacer()
                
                // Reveal button for secret fields
                if isSecret {
                    Button(action: { isRevealed.toggle() }) {
                        Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                // Copy button with feedback
                Button(action: copyToClipboard) {
                    if didCopy {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "doc.on.doc.fill")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = value
        withAnimation {
            didCopy = true
        }
        // Reset the checkmark after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                didCopy = false
            }
        }
    }
}

struct WebsiteRow: View {
    let label: String
    let value: String
    
    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(value)
                Spacer()
                
                // Open in Safari Button
                Button(action: openWebsite) {
                    Image(systemName: "safari.fill")
                }
                .buttonStyle(BorderlessButtonStyle())

                // Copy Button
                Button(action: copyToClipboard) {
                    if didCopy {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "doc.on.doc.fill")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
    
    private func openWebsite() {
        // Ensure the URL is valid, adding "https://" if needed
        var urlString = value
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = value
        withAnimation { didCopy = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { didCopy = false }
        }
    }
}

//#Preview {
//    HelperViews()
//}
