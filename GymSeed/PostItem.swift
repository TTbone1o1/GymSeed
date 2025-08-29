//
//  PostItem.swift
//  GymSeed
//
//  Created by Abraham May on 8/11/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

struct PostItem: Identifiable {
    let id: String
    let imageURL: String
    let caption: String
    let createdAt: Timestamp?
    let uid: String
}

// FeedStore.swift
@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [PostItem] = []
    @Published var didLoad = false
    @Published var displayName: String?   // ← add this

    private var listener: ListenerRegistration?
    private var profileListener: ListenerRegistration?

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stop()
        didLoad = false

        // 🔹 Listen for posts
        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                if let err {
                    print("❌ feed listener:", err.localizedDescription)
                    self?.didLoad = true
                    return
                }
                self?.posts = snap?.documents.compactMap { doc in
                    let data = doc.data()
                    return PostItem(
                        id: doc.documentID,
                        imageURL: data["imageURL"] as? String ?? "",
                        caption: data["caption"] as? String ?? "",
                        createdAt: data["createdAt"] as? Timestamp,
                        uid: data["uid"] as? String ?? ""
                    )
                } ?? []
                self?.didLoad = true
            }

        // 🔹 Listen for profile
        profileListener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] doc, err in
                if let err {
                    print("❌ profile listener:", err.localizedDescription)
                    return
                }
                self?.displayName = doc?.data()?["displayName"] as? String
            }
    }

    func stop() {
        listener?.remove()
        profileListener?.remove()
        listener = nil
        profileListener = nil
    }
}
