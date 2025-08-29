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
    
    var body: some View {
        ZStack {
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
            .frame(width: 133, height: 162) // profile size
            .clipped()
            .cornerRadius(16)
            .overlay( // 🔹 white border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 5)
            )
//            TODO come back if needed
//            VStack {
//                Spacer()
//                Text(caption)
//                    .multilineTextAlignment(.center)
//                    .font(.system(size: 12, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                    .padding(.bottom, 8)
//            }
            .frame(width: 133, height: 162)
        }
    }
}
