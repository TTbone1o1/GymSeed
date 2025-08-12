//
//  SignUpPage.swift
//  GymSeed
//
//  Created by Abraham may on 8/5/25.
//

import SwiftUI

struct SignUpPage: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .bold()
            
            AppleSignInButton { isNew, fullName in
                if isNew {
                    // Create users/{uid} in Firestore
                    Task {
                        await UserProvisioning.createUserIfNeeded(
                            isNewUser: true,
                            fullName: fullName
                        )
                    }
                    // Ensure RootView routes to Onboarding next
                    hasCompletedOnboarding = false
                }
            }
        }
        .padding()
    }
}
