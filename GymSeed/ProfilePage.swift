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
                ZStack {
                    let rotations: [Double] = [-9, -21.32, 20.25, 76.98]

                    ForEach(Array(profileStore.posts.prefix(4).enumerated().reversed()), id: \.element.id) { index, post in
                        ProfilePostedCard(
                            imageURL: post.imageURL,
                            caption: post.caption
                        )
                        .rotationEffect(.degrees(rotations[index]))
                        .offset(y: CGFloat(index) * 5) // small stagger
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.top, -170)
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
