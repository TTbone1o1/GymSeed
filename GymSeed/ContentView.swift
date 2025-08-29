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
    
    var body: some View {
        ZStack {
            // main area
            GeometryReader { geo in
                ZStack {
                    if !feed.didLoad {
                        ProgressView("Loading…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if feed.posts.isEmpty {
                        // 🌟 Your original collage
                        ZStack {
                            PhotoCard(imageName: "image11", offset: CGSize(width: -140, height: -50), rotation: -20)
                            PhotoCard(imageName: "image2",  offset: CGSize(width: -270, height:  80), rotation: -20)
                            PhotoCard(imageName: "image3",  offset: CGSize(width:  -65, height: -230), rotation:  10)
                            PhotoCard(imageName: "image8",  offset: CGSize(width: -105, height: -235), rotation: -15)
                            PhotoCard(imageName: "image5",  offset: CGSize(width:  220, height:   50), rotation:   5)
                            PhotoCard(imageName: "image6",  offset: CGSize(width:  160, height:  -10), rotation: -15)
                            PhotoCard(imageName: "image7",  offset: CGSize(width:  -35, height:  -35), rotation:  15)
                            PhotoCard(imageName: "image4",  offset: CGSize(width:   60, height:  -30), rotation: -15)
                            PhotoCard(imageName: "image9",  offset: CGSize(width:   90, height: -230), rotation:   5)
                            Text("GymSeed")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .offset(y: 150)
                        }
                        .offset(y: -120)
                    } else {
                        // 📜 Scrollable feed (26pt gaps)
                        
                        VStack() {
                            if let name = displayName {
                                Text("Welcome, \(name)!")
                                    .font(.title2.bold())
                                    .offset(y: 150)
                            }
                                
                            
                            FeedView(posts: feed.posts)   // ← your actual feed
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .background(Color(.systemBackground))
                .clipped(antialiased: true)
                //                .clipped()
            }
            .ignoresSafeArea()               // keep your full-bleed collage if you like
            
            // ✅ Float the camera button — no white bar behind it
            VStack {
                Spacer()
                
                Spacer()
                AddPhotoPrompt(hasPosted: !feed.posts.isEmpty)
                    .buttonStyle(.plain)
                
                    .padding(.bottom, 20) // clears the home indicator
                
            }
            .allowsHitTesting(true)
        }
        .onAppear {
            Task { @MainActor in
                feed.start()
                await loadDisplayName()
            }
        }

        .onDisappear { Task { @MainActor in feed.stop() } }
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




#Preview { ContentView() }
