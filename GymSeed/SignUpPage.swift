//
//  SignUpPage.swift
//  GymSeed
//
//  Created by Abraham may on 8/5/25.
//

import SwiftUI

struct SignUpPage: View {
    var onSignedIn: () -> Void

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()

            AppleSignInButton(onSuccess: onSignedIn)
        }
        .padding()
    }
}
