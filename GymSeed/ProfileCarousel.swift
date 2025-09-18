//
//  ProfileCarousel.swift
//  GymSeed
//
//  Created by Abraham May on 9/7/25.
//

import SwiftUI

struct ProfileCarousel: View {
    let posts: [PostItem]
    @State private var selectedPostID: String?   // track tapped post

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(posts) { post in
                    ProfilePostedCard(
                        imageURL: post.imageURL,
                        caption: post.caption,
                        createdAt: post.createdAt,
                        isSelected: selectedPostID == post.id   // pass down state
                    )
                    .shadow(radius: 6)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if selectedPostID == post.id {
                                selectedPostID = nil // deselect if tapped again
                            } else {
                                selectedPostID = post.id
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

