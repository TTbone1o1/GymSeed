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
                    case .failure(_): Rectangle().fill(.gray.opacity(0.25))
                        .overlay(Image(systemName: "exclamationmark.triangle"))
                    @unknown default: Rectangle().fill(.gray.opacity(0.15))
                    }
                }
                .frame(width: 313, height: 421)
                .clipped()
                .cornerRadius(16)

                // Caption centered on the image
                Text(caption)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.55))
                    .clipShape(Capsule())
                    .frame(width: 313) // centers the capsule on the card
            }
        }
    }
