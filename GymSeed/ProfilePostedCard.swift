//
//  ProfilePostedCard.swift
//  GymSeed
//
//  Created by Abraham May on 8/28/25.
//

import SwiftUI

struct ProfilePostedCard: View {
    let imageURL: String
    let caption: String
    let createdAt: Date   // 🔹 Firestore date
    var isSelected: Bool = false   // 🔹 new flag

    // 🔹 formatter for "Aug 5"
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }

    var body: some View {
        VStack(spacing: 5) {
            // 🔹 date pill ABOVE the image
            Text(dateText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 62, height: 30)
                .background(Color.red)
                .cornerRadius(22)

            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    Rectangle().fill(.gray.opacity(0.15))
                case .failure(_):
                    Rectangle().fill(.gray.opacity(0.25))
                        .overlay(Image(systemName: "exclamationmark.triangle"))
                @unknown default:
                    Rectangle().fill(.gray.opacity(0.15))
                }
            }
            .frame(
                width: isSelected ? 217 : 133,
                height: isSelected ? 268 : 162
            )
            .clipped()
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white, lineWidth: 5))
            .animation(.spring(), value: isSelected)   // smooth size change
        }
    }
}
