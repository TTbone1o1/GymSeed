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

        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                if let err = err {
                    print("❌ profile posts listener:", err.localizedDescription)
                    self?.didLoad = true
                    return
                }
                self?.posts =
                    snap?.documents.compactMap { doc in
                        let data = doc.data()
                        return PostItem(
                            id: doc.documentID,
                            imageURL: data["imageURL"] as? String ?? "",
                            caption: data["caption"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?
                                .dateValue() ?? Date(),
                            uid: uid,
                            displayName: data["displayName"] as? String
                                ?? "Unknown"  // 👈 directly from post
                        )
                    } ?? []
                self?.didLoad = true
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}
