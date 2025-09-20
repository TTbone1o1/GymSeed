//
//  UserBadge.swift
//  GymSeed
//
//  Created by Abraham May on 9/18/25.
//

import SwiftUI

struct UserBadge: View {
    let name: String
    let profilePictureURL: String   // 👈 add photoURL support

    var body: some View {
        HStack(spacing: 6) {
            AsyncImage(url: URL(string: profilePictureURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .empty: Circle().fill(Color.gray.opacity(0.3))
                case .failure(_):
                    Circle().fill(Color.red.opacity(0.3))
                        .overlay(Image(systemName: "person.fill.questionmark"))
                @unknown default: Circle().fill(Color.gray.opacity(0.3))
                }
            }
            .transaction { $0.animation = nil } // 👈 add this
            .frame(width: 50, height: 50)
            .clipShape(Circle())


            Text(name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.blue)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        UserBadge(name: "Alex", profilePictureURL: "")
        UserBadge(name: "Alexandria Johnson", profilePictureURL: "https://picsum.photos/200")
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
