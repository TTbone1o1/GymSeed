//
//  ProfilePage.swift
//  GymSeed
//
//  Created by Abraham may on 8/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePage: View {
    @StateObject private var feed = FeedStore()
    @State private var profileURL: URL?
// 👈 use the same feed store

    var body: some View {
        VStack(spacing: 20) {
            OnboardingUploadProfile(didUpload: .constant(false))
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)

            Spacer()

            if !feed.didLoad {
                ProgressView("Loading…")
            } else if feed.posts.isEmpty {
                Text("No posts yet")
                    .foregroundColor(.gray)
            } else {
                ZStack {
                    ForEach(feed.posts.indices.reversed(), id: \.self) { i in
                        ProfilePostedCard(
                            imageURL: feed.posts[i].imageURL,
                            caption: feed.posts[i].caption
                        )
                        .rotationEffect(.degrees(Double(i) * 15 - 15))
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.top, -170)
            }

            Spacer()
        }
        .padding(.top, 50)
        .onAppear { feed.start()  }   // 👈 starts listener
        .onDisappear { feed.stop() } // 👈 stops listener
    }
}



#Preview {
    ProfilePage()
}
