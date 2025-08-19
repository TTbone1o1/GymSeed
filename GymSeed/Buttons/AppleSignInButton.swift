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
import FirebaseFirestore   // ← add this

struct AppleSignInButton: View {
    var onAuthResult: (_ isNewUser: Bool, _ fullName: PersonNameComponents?) -> Void

    @State private var currentNonce: String?
    private let usersCollection = "users" // ← change to "User" if you prefer that name

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

            // 🔹 Create/merge Firestore user doc
            Task { @MainActor in
                await provisionUserDocument(isNewUser: isNew, appleName: appleIDCredential.fullName)
            }

            // Keep your existing flow
            DispatchQueue.main.async {
                onAuthResult(isNew, appleIDCredential.fullName)
            }
        }
    }

    // Create (or merge) users/{uid} with basic fields
    @MainActor
    private func provisionUserDocument(isNewUser: Bool, appleName: PersonNameComponents?) async {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // Prefer Apple name on first sign-in, fall back to Firebase displayName
        let displayName = appleName?.formatted(.name(style: .medium)) ?? user.displayName

        var data: [String: Any] = [
            "provider": "apple",
            "lastSignInAt": FieldValue.serverTimestamp()
        ]
        if isNewUser {
            data["createdAt"] = FieldValue.serverTimestamp()
        }
        if let email = user.email { data["email"] = email }
        if let displayName { data["displayName"] = displayName }

        do {
            try await db.collection(usersCollection).document(user.uid).setData(data, merge: true)
            print("✅ Firestore user doc upserted at \(usersCollection)/\(user.uid)")

            // (Optional) create a tiny marker so the subcollection shows up in console immediately
            // Comment out if you don't want a marker.
            if isNewUser {
                try await db.collection(usersCollection).document(user.uid)
                    .collection("posts")
            }
        } catch {
            print("❌ Failed provisioning user doc:", error.localizedDescription)
        }
    }

    // nonce + sha256 helpers ...
    private func randomNonceString(length: Int = 32) -> String { /* unchanged */
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess { fatalError("Unable to generate nonce.") }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonceChars = randomBytes.map { charset[Int($0) % charset.count] }
        return String(nonceChars)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
