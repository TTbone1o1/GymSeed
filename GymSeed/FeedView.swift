//
//  FeedView.swift
//  GymSeed
//
//  Created by Abraham May on 8/11/25.
//


// FeedView.swift
import SwiftUI

struct FeedView: View {
    let posts: [PostItem]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 35) {
                ForEach(posts) { post in
                    PostedCard(imageURL: post.imageURL, caption: post.caption, displayName: post.displayName, profilePictureURL: post.profilePictureURL)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 110)
        }
        .background(Color.clear)
    }
}

