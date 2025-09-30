//
//  OnboardingImage.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct OnboardingImage: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            // First image - 139x179
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 139, height: 179)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 6)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
                .offset(x: -90, y: 55)
                .rotationEffect(.degrees(-12))

            
            // Last image - 144x185
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 144, height: 185)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 6)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
                .offset(x: 80, y: -45)
                .rotationEffect(.degrees(14))
            
            // Second image - 174x220
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 174, height: 220)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 6)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
                .offset(x: 0, y: 20)
                .rotationEffect(.degrees(10))

        }

    }
}

#Preview {
    OnboardingImage(imageName: "image11")
}
