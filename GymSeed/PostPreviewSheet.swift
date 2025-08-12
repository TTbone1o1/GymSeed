//
//  PostPreviewSheet.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//


import SwiftUI

struct PostPreviewSheet: View {
    let image: UIImage
    var onCancel: () -> Void
    var onPosted: () -> Void

    @State private var caption = ""
    @State private var isPosting = false
    @State private var errorText: String?

    var body: some View {
        ZStack {
            // Full-screen image
            GeometryReader { geo in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
            }

            // Bottom gradient for legibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Top bar (back/retake)
            VStack {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)

                Spacer()

                // Caption + Post controls
                VStack(spacing: 12) {
                    TextField("Write a caption", text: $caption, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                    Button {
                        Task {
                            isPosting = true; errorText = nil
                            do {
                                // Optional: downscale for speed
                                // let resized = image.resized(maxDimension: 1400)
                                _ = try await PostService.createPost(
                                    image: image,
                                    caption: caption.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                                onPosted()
                            } catch {
                                errorText = error.localizedDescription
                            }
                            isPosting = false
                        }
                    } label: {
                        Text(isPosting ? "Posting…" : "Post")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)     // white button
                            .foregroundColor(.black)      // black text
                            .cornerRadius(14)
                            .shadow(radius: 2, y: 1)
                    }
                    .padding(.horizontal, 16)
                    .disabled(isPosting)

                    if let errorText {
                        Text(errorText)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.bottom, 18)
            }
        }
        .statusBar(hidden: true)
        .ignoresSafeArea(.keyboard) // keep the image full-bleed
    }
}
