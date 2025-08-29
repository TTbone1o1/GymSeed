//
//  OnboardingUploadProfile.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

//
//  OnboardingUploadProfile.swift
//  GymSeed
//
//  Created by Abraham May on 8/3/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingUploadProfile: View {
    @State private var isBouncing = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?            // local preview while picking
    @State private var remoteURL: URL?                    // last saved photoURL from Firestore
    @State private var isUploading = false
    @State private var isLoadingRemote = false
    @State private var errorMessage: String?
    @Binding var didUpload: Bool

    var body: some View {
        VStack(spacing: 8) {
            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#CDCDCD").opacity(0.3))
                        .frame(width: 150, height: 150)

                    // 1) show freshly-picked image (fastest feedback)
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable().scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }
                    // 2) else show remote saved photo if available
                    else if let remoteURL {
                        AsyncImage(url: remoteURL) { phase in
                            switch phase {
                            case .empty:
                                if isLoadingRemote { ProgressView() }
                                else { Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.gray) }
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure(_):
                                Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    }
                    // 3) fallback placeholder
                    else {
                        Image(systemName: "person.fill")
                            .resizable().scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }

                    if isUploading {
                        Circle().fill(Color.black.opacity(0.35))
                            .frame(width: 150, height: 150)
                        ProgressView().progressViewStyle(.circular)
                    }
                }
                .contentShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                .scaleEffect(isBouncing ? 1.1 : 1.0)
                .animation(.interpolatingSpring(stiffness: 300, damping: 5), value: isBouncing)
            }
            .onTapGesture {
                isBouncing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isBouncing = false }
            }
            .onChange(of: pickerItem) { _, newItem in
                Task { await handlePickedItem(newItem) }
            }
            // Load the last saved photo when this view appears
            .task { await loadLatestProfilePhoto() }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Handling

    private func handlePickedItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        errorMessage = nil

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run { selectedImage = uiImage }
                try await uploadAndSave(uiImage)
                // after upload, clear the local preview so we show the authoritative remote image
                await MainActor.run { selectedImage = nil }
            } else {
                await MainActor.run { errorMessage = "Could not read the selected image." }
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    private func uploadAndSave(_ image: UIImage) async throws {
        guard Auth.auth().currentUser?.uid != nil else {
            await MainActor.run { errorMessage = "You must be signed in." }
            return
        }

        await MainActor.run { isUploading = true }
        defer { Task { await MainActor.run { isUploading = false } } }

        do {
            // Must return an HTTPS download URL string
            let urlString = try await ProfilePhotoService.uploadProfilePhoto(image)

            // Save a doc under users/{uid}/profile_pictures/{photoId}
            try await saveSubcollectionDoc(photoURL: urlString)

            // Update what we display immediately
            if let url = URL(string: urlString) {
                await MainActor.run { remoteURL = url
                    didUpload = true}
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
            throw error
        }
    }

    private func saveSubcollectionDoc(photoURL: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let photoId = UUID().uuidString
        let now = Date()

        let data: [String: Any] = [
            "photoId": photoId,
            "photoURL": photoURL,
            "createdAt": Timestamp(date: now),
            "updatedAt": Timestamp(date: now)
        ]

        try await db.collection("users").document(uid)
            .collection("profile_pictures")
            .document(photoId)
            .setData(data, merge: false)
    }

    private func loadLatestProfilePhoto() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await MainActor.run { isLoadingRemote = true; errorMessage = nil }
        defer { Task { await MainActor.run { isLoadingRemote = false } } }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users").document(uid)
                .collection("profile_pictures")
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
                .getDocuments()

            if let doc = snapshot.documents.first,
               let urlString = doc.data()["photoURL"] as? String,
               let url = URL(string: urlString) {
                await MainActor.run { remoteURL = url }
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
