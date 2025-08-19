//
//  ContentView.swift
//  GymSeed
//
//  Created by Abraham may on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var feed = FeedStore()

    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    if !feed.didLoad {
                        // First load → show a spinner instead of flashing the collage
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
                    } else {
                        // 📜 Scrollable feed (26pt gaps)
                        FeedView(posts: feed.posts)   // ← pass data in
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .background(Color(.systemBackground))
                .clipped()
            }
            .ignoresSafeArea()
            .padding(.bottom, 50)

            Spacer()

            // Show text + button when no posts; button-only otherwise
            AddPhotoPrompt(hasPosted: !feed.posts.isEmpty)
                .padding(.bottom, 40)
        }
        .onAppear { Task { @MainActor in feed.start() } }
        .onDisappear { Task { @MainActor in feed.stop() } }
    }
}

#Preview { ContentView() }
