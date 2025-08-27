//
//  CameraUi.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

import SwiftUI

struct CameraUi: View {
    @StateObject private var camera = CameraService()
    @Environment(\.dismiss) private var dismiss

    @State private var previewImage: UIImage? = nil
    @State private var caption: String = ""
    @State private var isPosting = false
    @State private var errorText: String?
    @FocusState private var captionFocused: Bool

    var onPosted: (() -> Void)? = nil

    var body: some View {
        ZStack {
            if let img = previewImage {
                // ======= FULL-SCREEN PREVIEW =======
                ZStack {
                    Color.black.ignoresSafeArea()

                    GeometryReader { geo in
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)   // fill both dimensions, crop if needed
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()                         // cut off overflow instead of letterbox
                    }
                    .ignoresSafeArea()


                    // Centered caption (stays centered even when keyboard shows)
                    TextField("Write a captions", text: $caption, axis: .vertical)
                        .focused($captionFocused)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding(.vertical, 12)
                        .frame(width: 270)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .zIndex(1)

                    // Bottom Post button (fixed; won’t be pushed by keyboard)
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
                                dismiss()
                            } catch {
                                errorText = error.localizedDescription
                            }
                            isPosting = false
                        }
                    } label: {
                        Text(isPosting ? "Posting…" : "Post")
                            .fontWeight(.semibold)
                            .frame(width: 270, height: 76)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 37, style: .continuous))
                            .shadow(radius: 2, y: 1)
                    }
                    .disabled(isPosting)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .zIndex(1)
                }
                // ✅ Keep the back button ABOVE everything using an overlay
                .overlay(alignment: .topLeading) {
                    HStack {
                        Button {
                            previewImage = nil
                            caption = ""
                            camera.start()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5)) // more contrast on bright images
                                .clipShape(Circle())
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16) // add a little top inset; adjust if needed per device
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
        .ignoresSafeArea(.keyboard) // keep layout stable when keyboard appears
        .toolbar {
            // Optional keyboard toolbar "Done"
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { captionFocused = false }
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onReceive(camera.$capturedImage.compactMap { $0 }) { image in
            previewImage = image

        }
        .onTapGesture {
            if captionFocused { captionFocused = false }
        }
        // Surface any posting errors with a lightweight alert
        .alert("Error", isPresented: .constant(errorText != nil), actions: {
            Button("OK") { errorText = nil }
        }, message: {
            Text(errorText ?? "")
        })
    }
}
