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
    let displayName: String
    
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
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.95), .clear]),
                            startPoint: .bottom,
                            endPoint: .center
                        )
                    )
                    .cornerRadius(32)
                    .blendMode(.multiply) // darkens instead of stacking color
            )
            .overlay(
                            // 👇 Badge in the top-left corner
                            VStack {
                                UserBadge(name: displayName)
                                    .padding([.top, .leading], 12)
                                Spacer()
                            },
                            alignment: .topLeading
                        )
                        .overlay(
                            // 👇 Caption at bottom
                            VStack {
                                Spacer()
                                Text(caption)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 25, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 32)
                            }
                            .frame(width: 313, height: 421)
                        )
        }
    }
}
