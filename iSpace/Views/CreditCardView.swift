//
//  CreditCardView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 06/09/25.
//

import SwiftUI

struct CreditCardView: View {
    let item: StoredItem
    let details: CardDetails
    
    var cardTypeLogo: String {
        let number = details.cardNumber.filter { $0.isNumber }
        if number.hasPrefix("4") {
            return "visaLogo"
        } else if number.hasPrefix("5") {
            return "mastercardLogo"
        }
        return ""
    }
    
    var formattedCardNumber: String {
        let number = details.cardNumber.filter { $0.isNumber }
        guard number.count > 4 else {
            return number
        }
        
        let lastFourDigits = String(number.suffix(4))
        let maskedPart = String(repeating: "•", count: number.count - 4)
        let combined = maskedPart + lastFourDigits
        
        var result = ""
        for (index, char) in combined.enumerated() {
            if index > 0 && index % 4 == 0 {
                result.append(" ")
            }
            result.append(char)
        }
        return result
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(white: 0.1), Color(white: 0.25)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)

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
                    Text(item.name.uppercased())
                        .font(.headline)
                        .bold()
                    Spacer()
                    Image(systemName: "wifi")
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
                }
            }
            .foregroundColor(.white)
            .padding(25)
        }
        .aspectRatio(1.586, contentMode: .fit)
    }
}




//#Preview {
//    CreditCardView()
//}
