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

@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [PostItem] = []
    private var listener: ListenerRegistration?

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stop()

        listener = Firestore.firestore()
            .collection("posts")
            .whereField("uid", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                if let err { print("❌ feed listener:", err.localizedDescription); return }
                Task { @MainActor in
                    self?.posts = snap?.documents.map { doc in
                        let d = doc.data()
                        return PostItem(
                            id: doc.documentID,
                            imageURL: d["imageURL"] as? String ?? "",
                            caption: d["caption"] as? String ?? "",
                            createdAt: d["createdAt"] as? Timestamp,
                            uid: d["uid"] as? String ?? ""
                        )
                    } ?? []
                }
            }
    }

    func stop() {
        listener?.remove(); listener = nil
    }
}
