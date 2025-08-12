//
//  CameraUi.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

//
//  CameraUi.swift
//  GymSeed
//

import SwiftUI

struct CameraUi: View {
    @StateObject private var camera = CameraService()
    @Environment(\.dismiss) private var dismiss

    // Preview state
    @State private var previewImage: UIImage? = nil
    @State private var caption: String = ""
    @State private var isPosting = false
    @State private var errorText: String?

    /// Optional hook if the parent wants to react after a successful post.
    var onPosted: (() -> Void)? = nil

    var body: some View {
        ZStack {
            if let img = previewImage {
                // ======= FULL-SCREEN PREVIEW =======
                GeometryReader { geo in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()
                }

                // Bottom fade for legibility
                LinearGradient(colors: [.clear, .black.opacity(0.55)],
                               startPoint: .center, endPoint: .bottom)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack {
                    // Top-left back/retake
                    HStack {
                        Button {
                            // Retake: go back to live camera
                            previewImage = nil
                            caption = ""
                            camera.start()
                        } label: {
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

                    // Caption + Post
                    VStack(spacing: 12) {
                        TextField("Write a caption", text: $caption, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)

                        Button {
                            Task {
                                guard let img = previewImage else { return }
                                isPosting = true; errorText = nil
                                do {
                                    _ = try await PostService.createPost(
                                        image: img,
                                        caption: caption.trimmingCharacters(in: .whitespacesAndNewlines)
                                    )
                                    onPosted?()
                                    dismiss()       // close camera after posting
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
                                .background(Color.white)   // white button
                                .foregroundColor(.black)   // black text
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
                .statusBar(hidden: true)

            } else {
                // ======= LIVE CAMERA =======
                CameraView(service: camera)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    Button {
                        camera.capturePhoto()
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(.black.opacity(0.1), lineWidth: 2))
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onReceive(camera.$capturedImage.compactMap { $0 }) { image in
            // Switch to preview mode and pause camera
            previewImage = image
            camera.stop()
        }
    }
}
