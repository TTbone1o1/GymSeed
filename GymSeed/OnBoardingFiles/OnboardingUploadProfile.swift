//
//  OnboardingUploadProfile.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct OnboardingUploadProfile: View {
    @State private var isBouncing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#CDCDCD").opacity(0.3))
                .frame(width: 150, height: 150)
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .scaleEffect(isBouncing ? 1.1 : 1.0)
        .animation(.interpolatingSpring(stiffness: 300, damping: 5), value: isBouncing)
        .onTapGesture {
            isBouncing = true
            
            // Reset to original scale after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isBouncing = false
            }
        }
    }
}

#Preview {
    OnboardingUploadProfile()
}
