import SwiftUI

struct Onboarding<Visual: View>: View {
    let customVisual: (() -> Visual)?
    let buttonText: String
    let isButtonEnabled: Bool
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Background layer
            Color("BackGroundColor")
                .ignoresSafeArea()

            // Foreground content
            VStack {
                if let visual = customVisual {
                    visual()
                }

                Spacer()

                OnboardingButton(
                    title: buttonText,
                    action: onButtonTap,
                    isEnabled: isButtonEnabled
                )
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
