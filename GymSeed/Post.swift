//
//  PostService.swift
//  GymSeed
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct Post {
    let id: String
    let uid: String
    let caption: String
    let imageURL: String
    let createdAt: Timestamp
}

enum StorageRefs {
    static let storage = Storage.storage(url: "gs://gymseed-e292d.firebasestorage.app")
}

enum PostService {

    /// Uploads an image to Storage and writes a Firestore doc in `posts/{postId}`.
    /// Returns the `postId` on success.
    @MainActor
    static func createPost(image: UIImage, caption: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "PostService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "PostService", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Bad image"])
        }

        let postId = UUID().uuidString

        // 1) Upload image to Storage at posts/<uid>/<postId>.jpg
        let storageRef = Storage.storage().reference()
            .child("posts")
            .child(uid)                   // ← keep this to match your Storage rules
            .child("\(postId).jpg")

        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        print("→ starting upload to:", storageRef.fullPath)
        do {
            _ = try await storageRef.putDataAsync(data, metadata: meta)
            print("✅ upload ok to:", storageRef.fullPath)
        } catch {
            print("❌ upload failed:", error)
            throw error
        }

        // 2) Get a download URL
        let url: URL
        do {
            url = try await storageRef.downloadURL()
            print("🔗 downloadURL:", url.absoluteString)
        } catch {
            print("❌ downloadURL failed:", error)
            throw error
        }

        // 3) Create Firestore doc
        let doc: [String: Any] = [
            "uid": uid,
            "caption": caption,
            "imageURL": url.absoluteString,
            "createdAt": FieldValue.serverTimestamp()
        ]

        do {
            try await Firestore.firestore()
                .collection("posts")
                .document(postId)
                .setData(doc)
            print("📝 Firestore doc created: posts/\(postId)")
        } catch {
            print("❌ Firestore write failed:", error)
            throw error
        }

        return postId
    }

    /// Query latest posts for a simple feed (optional helper).
    static func latestPostsQuery(limit: Int = 50) -> Query {
        Firestore.firestore()
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
    }
}
