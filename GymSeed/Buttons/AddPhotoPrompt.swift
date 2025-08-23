//
//  AddPhotoPrompt.swift
//  GymSeed
//

import SwiftUI

struct AddPhotoPrompt: View {
    /// Pass true when the user already has at least one post.
    let hasPosted: Bool

    @State private var showCamera = false

    var body: some View {
        Group {
            if hasPosted {
                // Button only, no container/background so it doesn't cover images
                button
            } else {
                // Text + button for first-time users
                VStack(spacing: 12) {
                    Text("Add a Photo to start editing")
                        .font(.headline)
                    button
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear) // make sure nothing opaque sits behind
        .fullScreenCover(isPresented: $showCamera) {
            // If your CameraUi takes onPosted: () -> Void
            CameraUi {
                // camera dismisses itself after posting; nothing else required
                showCamera = false
            }
            // If your CameraUi instead uses onCapture: (UIImage) -> Void,
            // change to: CameraUi(onCapture: { _ in showCamera = false })
        }
    }

    private var button: some View {
        Button {
            showCamera = true
        } label: {
            ZStack {
                Circle().fill(Color(hex: "#3664E9")).frame(width: 67, height: 67)
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .buttonStyle(.plain)        // ← no automatic backgrounds/highlights
        .contentShape(Circle())     // tap target is the circle only
        .accessibilityLabel("Add photo")
    }

}
