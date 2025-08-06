//
//  AuthViewModal.swift
//  GymSeed
//
//  Created by Abraham may on 8/5/25.
//

import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            // Update user state
            self.user = user

            // ✅ Check if the user is still valid
            if let user = user {
                user.getIDTokenResult { _, error in
                    if let error = error {
                        print("❌ Token invalid or user deleted: \(error.localizedDescription)")
                        try? Auth.auth().signOut()
                        DispatchQueue.main.async {
                            self.user = nil
                        }
                    }
                }
            }
        }
    }
}

