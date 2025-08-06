//
//  AppleSignInButton.swift
//  GymSeed
//
//  Created by Abraham May on 8/5/25.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct AppleSignInButton: View {
    var onSuccess: () -> Void
    @State private var currentNonce: String?

    var body: some View {
        SignInWithAppleButton(.continue) { request in
            let nonce = randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleAuthorization(authorization)
            case .failure(let error):
                print("Sign in failed: \(error.localizedDescription)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            print("Failed to get credentials")
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: identityTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase sign-in failed: \(error.localizedDescription)")
            } else {
                print("✅ Firebase sign-in succeeded")
                onSuccess()
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce.")
            }

            randomBytes.forEach { byte in
                if remainingLength > 0 && byte < charset.count {
                    result.append(charset[Int(byte)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
