//
//  RootView.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var hasSignedIn: Bool = false

    var body: some View {
        Group {
            if !hasSignedIn {
                SignUpPage(onSignedIn: {
                    hasSignedIn = true
                })
            } else if !hasCompletedOnboarding {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
            } else {
                ContentView()
            }
        }
    }
}
