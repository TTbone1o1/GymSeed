//
//  ContentView.swift
//  GymSeed
//
//  Created by Abraham may on 7/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @StateObject private var feed = FeedStore()
    @State private var displayName: String?
    @State private var showUserSearch = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if let name = displayName {
                    HStack {
                        Spacer()
                        Text(name)
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 80)
                }
                
                FeedView(posts: feed.posts)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped(antialiased: true)
            // 👇 CircleBlur as background
            .background(
                CircleBlur()
                    .ignoresSafeArea()
            )
        }

        .ignoresSafeArea()
        
        // ✅ Overlay camera button
        .overlay(alignment: .bottom) {
            AddPhotoPrompt(hasPosted: !feed.posts.isEmpty)
                .buttonStyle(.plain)
                .padding(.bottom, 20)
        }
        
        // 🔍 User search sheet
        .sheet(isPresented: $showUserSearch) {
            AllUsersView()
                .presentationDetents([.medium, .large])
        }
        
        // 🔄 Lifecycle
        .onAppear {
            Task { @MainActor in
                feed.start()
                await loadDisplayName()
            }
        }
        .onDisappear {
            Task { @MainActor in feed.stop() }
        }
    }
    
    private func loadDisplayName() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            self.displayName = doc.get("displayName") as? String
        } catch {
            print("❌ Failed to load display name:", error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}




#Preview { ContentView() }
