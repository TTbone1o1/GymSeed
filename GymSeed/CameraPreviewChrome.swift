//
//  CameraPreviewChrome.swift
//  GymSeed
//
//  Created by Abraham May on 8/23/25.
//


//  CameraPreviewChrome.swift
import SwiftUI

struct CameraPreviewChrome: View {
    @Binding var caption: String
    var isPosting: Bool
    var onBack: () -> Void
    var onPost: () -> Void

    @FocusState private var captionFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // TOP BAR — back button, pinned by safe-area padding
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, max(proxy.safeAreaInsets.top, 6))

                // CENTER — caption field
                Spacer(minLength: 0)
                TextField("Write a caption", text: $caption, axis: .vertical)
                    .focused($captionFocused)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .frame(width: 270)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                Spacer(minLength: 0)

                // BOTTOM — 270x76 Post button, above home indicator
                Button(action: onPost) {
                    Text(isPosting ? "Posting…" : "Post")
                        .fontWeight(.semibold)
                        .frame(width: 270, height: 76)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 37, style: .continuous))
                        .shadow(radius: 2, y: 1)
                }
                .disabled(isPosting)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        // prevent keyboard from pushing the whole layout up
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // keyboard toolbar + tap-to-dismiss
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { captionFocused = false }
            }
        }
        .onTapGesture { if captionFocused { captionFocused = false } }
    }
}

#Preview("Chrome preview") {
    // simple background to see contrast; no ZStack required
    VStack {
        Spacer()
    }
    .background(Color.black.ignoresSafeArea())
    .overlay( // you can overlay this on your full-screen image in CameraUi
        CameraPreviewChrome(
            caption: .constant(""),
            isPosting: false,
            onBack: {},
            onPost: {}
        )
    )
    .preferredColorScheme(.dark)
}

