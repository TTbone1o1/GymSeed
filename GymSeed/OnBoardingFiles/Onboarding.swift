//
//  Onboarding.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct Onboarding: View {
    let rotatingText: [String]
    let buttonText: String
    let onButtonTap: () -> Void
    let isButtonEnabled: Bool
    let customVisual: AnyView?
    

    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 30) {
            if !rotatingText.isEmpty {
                Text(rotatingText[currentIndex])
                    .font(.title2)
                    .transition(.opacity)
                    .animation(.easeInOut, value: currentIndex)
            }
            
            if let visual = customVisual {
                visual
            }
            
            OnboardingButton(title: buttonText, action: onButtonTap, isEnabled: isButtonEnabled)
        }
        .padding()
        .onAppear {
            if rotatingText.count > 1 {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    currentIndex = (currentIndex + 1) % rotatingText.count
                }
            }
        }
    }
}
