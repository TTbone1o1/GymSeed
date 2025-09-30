import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SplashView: View {
    @Binding var showSplash: Bool
    
    @State private var profileImageURL: URL?
    @State private var displayName: String?

    var body: some View {
        ZStack {
            // 🔵 CircleBlur background at the top
            VStack {
                CircleBlur()
                    .frame(height: 250)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 🖼 Profile image with white stroke
                if let url = profileImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(40)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 3)
                    )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 3)
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        )
                }
                
                // 📝 Centered text
                if let name = displayName {
                    Text("Welcome back, \(name)!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                } else {
                    Text("GymSeed")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            Task {
                await loadUserInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }
    
    private func loadUserInfo() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            if let urlString = doc.data()?["photoURL"] as? String,
               let url = URL(string: urlString) {
                await MainActor.run { profileImageURL = url }
            }
            if let name = doc.data()?["displayName"] as? String {
                await MainActor.run { displayName = name }
            }
        } catch {
            print("❌ SplashView failed to load user info:", error.localizedDescription)
        }
    }
}
