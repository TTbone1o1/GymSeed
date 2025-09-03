import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct AllUsersView: View {
    @State private var users: [UserModel] = []
    
    var body: some View {
        NavigationView {
            List(users) { user in
                HStack(spacing: 12) {
                    // Profile picture
                    AsyncImage(url: URL(string: user.profilePictureURL)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
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
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.users = docs.compactMap { doc in
                    let data = doc.data()
                    return UserModel(
                        id: doc.documentID,
                        displayName: data["displayName"] as? String ?? "Unknown",
                        profilePictureURL: data["photoURL"] as? String ?? ""   // ✅ updated
                    )
                }
            } else if let error = error {
                print("❌ Error fetching users:", error.localizedDescription)
            }
        }
    }
}

struct UserModel: Identifiable {
    let id: String
    let displayName: String
    let profilePictureURL: String
}
