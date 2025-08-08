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
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 217, height: 328)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 6)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
    }
}

#Preview {
    OnboardingImage(imageName: "image11")
}
