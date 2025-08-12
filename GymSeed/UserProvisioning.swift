//
//  UserProvisioning.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

enum UserProvisioning {
    /// Creates users/{uid} the first time this account signs in.
    static func createUserIfNeeded(isNewUser: Bool,
                                   fullName: PersonNameComponents? = nil) async {
        guard isNewUser, let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "createdAt": FieldValue.serverTimestamp(),
            "provider": "apple"
        ]
        if let email = user.email { data["email"] = email }
        if let name = fullName?.formatted(.name(style: .medium)) ?? user.displayName {
            data["displayName"] = name
        }
        
        do {
            try await db.collection("users").document(user.uid).setData(data)
            print("✅ Created users/\(user.uid)")
        } catch {
            print("❌ Failed to create user doc:", error)
        }
    }
}
