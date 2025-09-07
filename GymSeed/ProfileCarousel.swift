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

#Preview {
    let samplePosts: [PostItem] = [
        PostItem(
            id: "1",
            imageURL: "https://picsum.photos/id/101/200/300",
            caption: "Leg day",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 5))!,
            uid: "user1"
        ),
        PostItem(
            id: "2",
            imageURL: "https://picsum.photos/id/102/200/300",
            caption: "Chest pump",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10))!,
            uid: "user2"
        ),
        PostItem(
            id: "3",
            imageURL: "https://picsum.photos/id/103/200/300",
            caption: "Back workout",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 15))!,
            uid: "user3"
        ),
        PostItem(
            id: "4",
            imageURL: "https://picsum.photos/id/104/200/300",
            caption: "Cardio time",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 20))!,
            uid: "user4"
        ),
        PostItem(
            id: "5",
            imageURL: "https://picsum.photos/id/105/200/300",
            caption: "Rest day stretch",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 25))!,
            uid: "user5"
        )
    ]
    
    return ProfileCarousel(posts: samplePosts)
}

