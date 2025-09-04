import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct AllUsersView: View {
    @State private var users: [UserModel] = []
    private let db = Firestore.firestore()
    private var currentUid: String? { Auth.auth().currentUser?.uid }
    
    var body: some View {
        NavigationView {
            List(users) { user in
                HStack(spacing: 12) {
                    // Profile picture
                    AsyncImage(url: URL(string: user.profilePictureURL)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.3))
                        case .failure(_):
                            Circle().fill(Color.red.opacity(0.3))
                                .overlay(Image(systemName: "person.fill.questionmark"))
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    
                    // Name
                    Text(user.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Follow / Unfollow button
                    Button {
                        toggleFollow(user)
                    } label: {
                        if user.isFollowing {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .font(.system(size: 20, weight: .bold))
                        } else {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Find Friends")
        }
        .onAppear {
            fetchUsers()
        }
    }
    
    private func fetchUsers() {
        guard let uid = currentUid else { return }
        
        db.collection("users").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            
            var tempUsers: [UserModel] = []
            let group = DispatchGroup()
            
            for doc in docs {
                let data = doc.data()
                let userId = doc.documentID
                let displayName = data["displayName"] as? String ?? "Unknown"
                let profilePic = data["photoURL"] as? String ?? ""
                
                if userId == uid { continue } // skip self
                
                group.enter()
                db.collection("users").document(uid)
                    .collection("following").document(userId)
                    .getDocument { followDoc, _ in
                        let isFollowing = followDoc?.exists ?? false
                        tempUsers.append(UserModel(
                            id: userId,
                            displayName: displayName,
                            profilePictureURL: profilePic,
                            isFollowing: isFollowing
                        ))
                        group.leave()
                    }
            }
            
            group.notify(queue: .main) {
                self.users = tempUsers
            }
        }
    }
    
    private func toggleFollow(_ user: UserModel) {
        guard let uid = currentUid else { return }
        
        let followingRef = db.collection("users").document(uid).collection("following").document(user.id)
        let followersRef = db.collection("users").document(user.id).collection("followers").document(uid)
        
        if user.isFollowing {
            // 🔴 Unfollow
            followingRef.delete()
            followersRef.delete()
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index].isFollowing = false
            }
        } else {
            // 🟢 Follow
            let data: [String: Any] = ["createdAt": Timestamp()]
            followingRef.setData(data)
            followersRef.setData(data)
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index].isFollowing = true
            }
        }
    }
}


struct UserModel: Identifiable {
    let id: String
    let displayName: String
    let profilePictureURL: String
    var isFollowing: Bool = false   // 👈 track state
}
