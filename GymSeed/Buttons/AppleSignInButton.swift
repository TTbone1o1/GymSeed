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
    var onAuthResult: (_ isNewUser: Bool, _ fullName: PersonNameComponents?) -> Void
    
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
                if let e = error as? ASAuthorizationError, e.code == .canceled {
                    print("Sign in canceled")
                } else {
                    print("Sign in failed: \(error.localizedDescription)")
                }
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
    }
    
    @MainActor
    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleIDCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            print("Missing Apple credentials/nonce")
            return
        }
        
        currentNonce = nil
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase sign-in failed: \(error.localizedDescription)")
                return
            }
            let isNew = authResult?.additionalUserInfo?.isNewUser ?? false
            // Report back whether this is a brand-new account + the Apple fullName (may be nil)
            DispatchQueue.main.async {
                onAuthResult(isNew, appleIDCredential.fullName)
            }
        }
    }
    
    // Faster, unbiased nonce generator shown in Firebase docs
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce.")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonceChars = randomBytes.map { charset[Int($0) % charset.count] }
        return String(nonceChars)
    }
    
    // Firebase expects a hex string of the SHA-256 digest
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
