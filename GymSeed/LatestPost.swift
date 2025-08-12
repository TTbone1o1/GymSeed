//
//  LatestPost.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//


// PostStore.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct LatestPost {
    let imageURL: String
    let caption: String
    let id: String
}

@MainActor
final class PostStore: ObservableObject {
    @Published var latest: LatestPost?
    private var listener: ListenerRegistration?

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stop()  // we're already on the main actor here

        listener = Firestore.firestore()
            .collection("posts")
            .whereField("uid", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snap, err in
                if let err = err {
                    print("❌ latest-post listener error:", err.localizedDescription)
                    // keep existing self?.latest; don't nil it on error
                    return
                }
                Task { @MainActor in
                    guard let doc = snap?.documents.first else {
                        self?.latest = nil
                        return
                    }
                    let d = doc.data()
                    self?.latest = LatestPost(
                        imageURL: d["imageURL"] as? String ?? "",
                        caption: d["caption"] as? String ?? "",
                        id: doc.documentID
                    )
                }
            }

    }

    func stop() {
        listener?.remove()
        listener = nil
    }


    deinit { }
}
