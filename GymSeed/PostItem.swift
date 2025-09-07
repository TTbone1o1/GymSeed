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
    let createdAt: Date   // always a Date in our app
    let uid: String       // so we know whose post it is
}

// FeedStore.swift
@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [PostItem] = []
    @Published var didLoad = false
    @Published var displayName: String?

    private var listeners: [ListenerRegistration] = []
    private var profileListener: ListenerRegistration?

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stop()
        didLoad = false

        let db = Firestore.firestore()

        // 1. Load following list
        db.collection("users").document(uid).collection("following").getDocuments { [weak self] snap, err in
            if let err = err {
                print("❌ failed to load following:", err.localizedDescription)
                self?.didLoad = true
                return
            }

            var uids: [String] = [uid] // include self
            if let docs = snap?.documents {
                uids.append(contentsOf: docs.map { $0.documentID })
            }

            // 2. Listen for posts from all uids
            for userId in uids {
                let listener = db.collection("users")
                    .document(userId)
                    .collection("posts")
                    .order(by: "createdAt", descending: true)
                    .addSnapshotListener { snap, err in
                        if let err = err {
                            print("❌ post listener:", err.localizedDescription)
                            return
                        }

                        var newPosts: [PostItem] = []
                        for doc in snap?.documents ?? [] {
                            let data = doc.data()
                            newPosts.append(PostItem(
                                id: doc.documentID,
                                imageURL: data["imageURL"] as? String ?? "",
                                caption: data["caption"] as? String ?? "",
                                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                                uid: userId
                            ))
                        }


                        // Replace posts for this userId and re-sort
                        self?.replacePosts(for: userId, with: newPosts)
                    }

                self?.listeners.append(listener)
            }

            self?.didLoad = true
        }

        // 3. Listen for profile (optional)
        profileListener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] doc, err in
                if let err {
                    print("❌ profile listener:", err.localizedDescription)
                    return
                }
                self?.displayName = doc?.data()?["displayName"] as? String
            }
    }

    private func replacePosts(for userId: String, with newPosts: [PostItem]) {
        // Remove old posts from this user
        posts.removeAll { $0.uid == userId }
        // Add new ones
        posts.append(contentsOf: newPosts)
        // Re-sort
        posts.sort { $0.createdAt > $1.createdAt }

    }

    func stop() {
        for l in listeners { l.remove() }
        listeners.removeAll()
        profileListener?.remove()
        profileListener = nil
    }
}
