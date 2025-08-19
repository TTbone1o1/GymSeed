//
//  FeedView.swift
//  GymSeed
//
//  Created by Abraham May on 8/11/25.
//


import SwiftUI

struct FeedView: View {
    let posts: [PostItem]              // ← data passed in

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 26) {  // 26pt gap
                ForEach(posts) { post in
                    PostedCard(imageURL: post.imageURL, caption: post.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
        }
    }
}
