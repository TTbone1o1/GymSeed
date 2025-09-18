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

//
//  FeedStore.swift
//  GymSeed
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [PostItem] = []
    @Published var didLoad = false
    @Published var displayName: String?

    private var listeners: [String: ListenerRegistration] = [:]   // keyed by userId
    private var profileListener: ListenerRegistration?
    private var followingListener: ListenerRegistration?
    
    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stop()
        didLoad = false

        let db = Firestore.firestore()
        
        // 👇 Listen to following list in real time
        followingListener = db.collection("users").document(uid)
            .collection("following")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    print("❌ following listener:", err.localizedDescription)
                    self.didLoad = true
                    return
                }
                
                var uids: Set<String> = [uid] // always include self
                for doc in snap?.documents ?? [] {
                    uids.insert(doc.documentID)
                }
                
                self.updateListeners(for: uids)
                self.didLoad = true
            }
        
        // 👇 Profile listener for displayName
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
    
    private func updateListeners(for newUids: Set<String>) {
        let db = Firestore.firestore()
        
        // 1. Remove listeners for unfollowed users
        for (uid, listener) in listeners {
            if !newUids.contains(uid) {
                listener.remove()
                listeners.removeValue(forKey: uid)
                posts.removeAll { $0.uid == uid }   // 👈 remove their posts in real time
            }
        }
        
        // 2. Add listeners for newly followed users
        for uid in newUids {
            if listeners[uid] == nil {
                let listener = db.collection("users")
                    .document(uid)
                    .collection("posts")
                    .order(by: "createdAt", descending: true)
                    .addSnapshotListener { [weak self] snap, err in
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
                                uid: uid
                            ))
                        }
                        
                        self?.replacePosts(for: uid, with: newPosts)
                    }
                listeners[uid] = listener
            }
        }
    }
    
    private func replacePosts(for userId: String, with newPosts: [PostItem]) {
        posts.removeAll { $0.uid == userId }
        posts.append(contentsOf: newPosts)
        posts.sort { $0.createdAt > $1.createdAt }
    }
    
    func stop() {
        for (_, l) in listeners { l.remove() }
        listeners.removeAll()
        profileListener?.remove()
        profileListener = nil
        followingListener?.remove()
        followingListener = nil
    }
}
