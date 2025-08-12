//
//  ProfilePhotoService.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//


import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

enum ProfilePhotoService {
    /// Uploads a JPEG profile photo, returns the download URL string, and saves it to users/{uid}.photoURL.
    @MainActor
    static func uploadProfilePhoto(_ image: UIImage) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ProfilePhotoService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "ProfilePhotoService", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Bad image"])
        }

        // 1) Upload to Storage
        let ref = Storage.storage().reference()
            .child("users")
            .child(uid)
            .child("profile.jpg")

        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: meta)

        // 2) Get a download URL
        let url = try await ref.downloadURL()

        // 3) Save to Firestore
        try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(["photoURL": url.absoluteString], merge: true)

        return url.absoluteString
    }
}
