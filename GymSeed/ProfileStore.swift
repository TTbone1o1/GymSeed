//
//  ProfileStore.swift
//  GymSeed
//
//  Created by Abraham May on 9/6/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published var posts: [PostItem] = []
    @Published var didLoad = false

    private var listener: ListenerRegistration?

    func start(for uid: String) {
        stop()
        didLoad = false

        let db = Firestore.firestore()

        // 👇 First load user profile info (name + photoURL)
        db.collection("users").document(uid).getDocument { [weak self] userDoc, _ in
            guard let self else { return }
            let userName = userDoc?.get("displayName") as? String ?? "Unknown"
            let profilePic = userDoc?.get("photoURL") as? String ?? ""

            // 👇 Then listen for their posts
            self.listener = db.collection("users")
                .document(uid)
                .collection("posts")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { [weak self] snap, err in
                    guard let self else { return }
                    if let err = err {
                        print("❌ profile posts listener:", err.localizedDescription)
                        self.didLoad = true
                        return
                    }

                    self.posts = snap?.documents.compactMap { doc in
                        let data = doc.data()
                        return PostItem(
                            id: doc.documentID,
                            imageURL: data["imageURL"] as? String ?? "",
                            caption: data["caption"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            uid: uid,
                            displayName: userName,          // 👈 from parent user doc
                            profilePictureURL: profilePic   // 👈 from parent user doc
                        )
                    } ?? []

                    self.didLoad = true
                }
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}
