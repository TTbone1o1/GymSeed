//
//  RootView.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

/// Shows the appropriate screen based on auth + onboarding status.
@MainActor
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if !authVM.didLoadAuthState {
                ProgressView("Checking session…")          // ← no flicker
            } else if authVM.user == nil {
                SignUpPage()
            } else if !hasCompletedOnboarding {
                OnboardingView { hasCompletedOnboarding = true }
            } else {
                MainPagerView()
            }
        }
    }
}
