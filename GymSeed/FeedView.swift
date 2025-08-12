//
//  FeedView.swift
//  GymSeed
//
//  Created by Abraham May on 8/11/25.
//


import SwiftUI

struct FeedView: View {
    @StateObject private var store = FeedStore()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 26) {            // ← 26pt gap between posts
                ForEach(store.posts) { post in
                    PostedCard(imageURL: post.imageURL, caption: post.caption)
                        .frame(maxWidth: .infinity) // center the 313px card
                }
            }
            .padding(.vertical, 16)
        }
        .onAppear { Task { @MainActor in store.start() } }
        .onDisappear { Task { @MainActor in store.stop() } }
    }
}
