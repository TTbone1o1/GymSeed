//
//  PostedCard.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//

// PostedCard.swift
import SwiftUI

struct PostedCard: View {
    let imageURL: String
    let caption: String
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .empty: Rectangle().fill(.gray.opacity(0.15))
                case .failure(_):
                    Rectangle().fill(.gray.opacity(0.25))
                        .overlay(Image(systemName: "exclamationmark.triangle"))
                @unknown default: Rectangle().fill(.gray.opacity(0.15))
                }
            }
            .frame(width: 313, height: 421)
            .clipped()
            .cornerRadius(32)

            // Caption centered on the image
            VStack {
                   Spacer() // pushes text down
                   Text(caption)
                       .multilineTextAlignment(.center)
                       .font(.system(size: 25, weight: .bold, design: .rounded))
                       .foregroundColor(.white)
                       .padding(.bottom, 32) // 32 points from bottom
               }
               .frame(width: 313, height: 421)
        }
    }
}
