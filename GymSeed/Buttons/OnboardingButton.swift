//
//  Button.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(isEnabled ? Color.blue : Color.black)
                .foregroundColor(.white)
                .cornerRadius(40)
        }
        .frame(width: 291)
        .disabled(!isEnabled) // ✅ Disables tap behavior
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingButton(title: "Enabled", action: {})
        OnboardingButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}
