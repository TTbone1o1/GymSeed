//
//  AuthViewModal.swift
//  GymSeed
//
//  Created by Abraham may on 8/5/25.
//

import FirebaseAuth
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var didLoadAuthState = false
    @Published var authError: Error?

    private var handle: AuthStateDidChangeListenerHandle?

    init(auth: Auth = .auth()) {
        handle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.didLoadAuthState = true          // ✅ finished first round-trip
            Task { await self?.ensureUserIsStillValid(user) }   // your existing check
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    /// Refreshes the user record; if it no longer exists, signs out.
    private func ensureUserIsStillValid(_ user: User?) async {
        guard let user else { return }
        do {
            try await user.reload()                               // <-- the key line
        } catch {
            // Account gone or token invalid → clean up
            await signOut(clearOnboarding: false)                 // see below
        }
    }

    /// Centralised sign-out helper so you can also call it from a “Log out” button.
    func signOut(clearOnboarding: Bool = true) async {
           do {
               try Auth.auth().signOut()
           } catch {
               authError = error                     // ← now compiles
           }

           user = nil                               // reset published state

           if clearOnboarding {
               UserDefaults.standard
                   .set(false, forKey: "hasCompletedOnboarding")
           }
       }
    
}
