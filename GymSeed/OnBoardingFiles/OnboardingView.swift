//
//  OnboardingView.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

enum OnboardingStep {
    case welcome
    case upload
    case username
}


struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step = 0 // current tab index
    @State private var name = ""
    @State private var didUpload = false
    @State private var circleOffset: CGFloat = 350 // start off-screen bottom

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Persistent background
            Color("BackGroundColor").ignoresSafeArea()
            CircleBlur()
                .offset(y: circleOffset)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: circleOffset)


            VStack {
                TabView(selection: $step) {
                    // Step 1
                    VStack {
                        Spacer()
                        OnboardingImage(imageName: "image11")
                        Spacer()
                        Text("Create and View \nYour Progress")
                            .font(.system(size: 37, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 40)
                       
                    }
                    .tag(0)

                    // Step 2
                    VStack {
                        Text("Upload a profile photo")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        Spacer()
                        OnboardingUploadProfile(didUpload: $didUpload)
                        Spacer()
                    }
                    .tag(1)

                    // Step 3
                    VStack {
                        Spacer()
                        OnboardingUserName(name: $name)
                        Spacer()
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // 👈 hides dots

                // Button area
                OnboardingButton(
                    title: buttonTitle,
                    action: handleNext,
                    isEnabled: isButtonEnabled
                )
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Helpers
    private var buttonTitle: String {
        switch step {
        case 0: return "Continue"
        case 1: return "Upload a profile picture"
        case 2: return "Continue"
        default: return "Continue"
        }
    }

    private var isButtonEnabled: Bool {
        switch step {
        case 0: return true
        case 1: return didUpload
        case 2: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private func handleNext() {
        if step == 0 {
            circleOffset = 0 // center
        } else if step == 1 {
            circleOffset = 0 // top
        }

        if step < 2 {
            withAnimation { step += 1 }
        } else {
            Task {
                await UserProvisioning.updateDisplayName(name)
                hasCompletedOnboarding = true
                onComplete()
            }
        }
    }
}




#Preview {
    OnboardingView(onComplete: {
        print("✅ Onboarding finished")
    })
}

