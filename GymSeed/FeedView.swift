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
                    PostedCard(imageURL: post.imageURL, caption: post.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.clear)
        .modifier(TopMargin150())   // ← see helper below
    }
}

// iOS17+: use contentMargins. Older iOS: use padding.
private struct TopMargin150: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.contentMargins(.top, 150, for: .scrollContent)
        } else {
            content.padding(.top, 150)
        }
    }
}

