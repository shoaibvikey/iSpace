//
//  CreditCardView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct CreditCardView: View {
    let details: CardDetails
    
    // A simple helper to guess the card type for the logo
    var cardTypeLogo: String {
        let number = details.cardNumber.filter { $0.isNumber }
        if number.hasPrefix("4") {
            return "visa-logo" // You'll need to add this image to your assets
        } else if number.hasPrefix("5") {
            return "mastercard-logo" // And this one
        }
        return "creditcard.fill" // Fallback SF Symbol
    }
    
    // A helper to format the card number
    var formattedCardNumber: String {
            let number = details.cardNumber.filter { $0.isNumber }
            guard number.count > 4 else {
                return number // Return as is if not long enough to mask
            }
            
            let lastFourDigits = String(number.suffix(4))
            let maskedPart = String(repeating: "•", count: number.count - 4)
            
            let combined = maskedPart + lastFourDigits
            
            var result = ""
            for (index, char) in combined.enumerated() {
                if index > 0 && index % 4 == 0 {
                    result.append(" ") // Add a space every 4 characters
                }
                result.append(char)
            }
            return result
        }

    var body: some View {
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(white: 0.1), Color(white: 0.25)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)

            // Diagonal line pattern
            VStack {
                ForEach(0..<10) { i in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: i * 40))
                        path.addLine(to: CGPoint(x: 400, y: i * 40 - 120))
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Secured By iSpace") // Example from image
                        .font(.caption.weight(.bold))
                    Spacer()
                    Image(systemName: "wifi") // Wi-fi symbol
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "simcard.fill")
                    .font(.largeTitle)
                    .foregroundColor(.yellow.opacity(0.8))
                
                Text(formattedCardNumber)
                    .font(.custom("Courier", size: 22).bold())
                    .tracking(2)
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(details.cardHolderName.uppercased())
                            .font(.headline)

                    }
                    Spacer()
                    // You would need to add actual Visa/Mastercard logos to your Assets.xcassets
                    // For now, this is a placeholder.
                    Text("VISA")
                        .font(.largeTitle.weight(.heavy))
                        .italic()
                }
            }
            .foregroundColor(.white)
            .padding(25)
        }
        .aspectRatio(1.586, contentMode: .fit) // Standard credit card aspect ratio
    }
}


//#Preview {
//    CreditCardView()
//}
