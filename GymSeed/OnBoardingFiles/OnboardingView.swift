//
//  OnboardingView.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step = 0
    @State private var name = ""
    var onComplete: () -> Void
    @State private var didUpload = false



    var body: some View {
        VStack {
            if step == 0 {
                Onboarding(
                    rotatingText: ["Take a Gym Photo", "Log Gym Workouts"],
                    buttonText: "Continue",
                    onButtonTap: {
                        step += 1
                    },
                    isButtonEnabled: true,
                    customVisual: AnyView(
                        OnboardingImage(imageName: "image11")
                    )
                )
            } else if step == 1 {
                Onboarding(
                    rotatingText: ["Upload a profile"],
                    buttonText: "Upload Photo",
                    onButtonTap: {
                        step += 1
                    },
                    isButtonEnabled: didUpload,
                    customVisual: AnyView(
                        OnboardingUploadProfile(didUpload: $didUpload)
                    )
                )
            } else if step == 2 {
                Onboarding(
                    rotatingText: [""],
                    buttonText: "Continue",
                    onButtonTap: {
                        Task {
                            await UserProvisioning.updateDisplayName(name)
                            hasCompletedOnboarding = true
                            onComplete() // ← fire your completion handler if needed
                        }
                    },
                    isButtonEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
                    customVisual: AnyView(
                        OnboardingUserName(name: $name)
                    )
                )
            }

        }
        .animation(.easeInOut, value: step)
        .transition(.slide)
    }
}

//#Preview {
//    OnboardingView()
//}
