//
//  PostComposer.swift
//  GymSeed
//
//  Created by Abraham May on 8/10/25.
//


import SwiftUI
import PhotosUI

struct PostComposer: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var preview: UIImage?
    @State private var caption: String = ""
    @State private var isPosting = false
    @State private var errorText: String?

    var onPosted: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Post").font(.headline)

            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    if let preview {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 160)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                    Text("Choose Photo")
                                }
                                .foregroundColor(.secondary)
                            }
                    }
                }
            }
            .onChange(of: pickerItem) { item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self),
                          let img = UIImage(data: data) else { return }
                    preview = img
                }
            }

            TextField("Write a caption…", text: $caption, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)

            Button {
                Task {
                    guard let preview else { errorText = "Pick a photo first"; return }
                    isPosting = true; errorText = nil
                    do {
                        _ = try await PostService.createPost(
                            image: preview,
                            caption: caption.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        caption = ""; self.preview = nil
                        onPosted?()
                    } catch {
                        errorText = error.localizedDescription
                    }
                    isPosting = false
                }
            } label: {
                Text(isPosting ? "Posting…" : "Post")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isPosting || preview == nil)

            if let errorText {
                Text(errorText).foregroundColor(.red).font(.footnote)
            }

            Spacer(minLength: 0)
        }
        .padding()
    }
}

#Preview { PostComposer() }
