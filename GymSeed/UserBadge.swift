//
//  UserBadge.swift
//  GymSeed
//
//  Created by Abraham May on 9/18/25.
//

import SwiftUI

struct UserBadge: View {
    let name: String

    var body: some View {

        ZStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)

                Text(name)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

            }
            .padding(.horizontal, 10)  // space inside the background
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.blue)
                    .frame(height: 68)
            )
        }

    }
}

#Preview {
    VStack(spacing: 16) {
        UserBadge(name: "Alex")
        UserBadge(name: "Alexandria Johnson") // 👈 long name works too
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
