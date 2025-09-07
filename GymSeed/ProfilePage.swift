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
    @StateObject private var profileStore = ProfileStore()

    var body: some View {
        VStack(spacing: 20) {
            OnboardingUploadProfile(didUpload: .constant(false))
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)

            Spacer()

            if !profileStore.didLoad {
                ProgressView("Loading…")
            } else if profileStore.posts.isEmpty {
                Text("No posts yet")
                    .foregroundColor(.gray)
            } else {
                ProfileCarousel(posts: profileStore.posts)
                    .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.top, 50)
        .onAppear {
            if let uid = Auth.auth().currentUser?.uid {
                profileStore.start(for: uid)
            }
        }
        .onDisappear { profileStore.stop() }
    }
}

#Preview {
    ProfilePage()
}
