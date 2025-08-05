//
//  AddPhotoPrompt.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct AddPhotoPrompt: View {
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Add a Photo to start editing")
                .font(.headline)

            Button(action: {
                showCamera = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#3664E9"))
                        .frame(width: 67, height: 67)

                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraUi()
            }

        }
        .padding(.bottom, 40)
    }
}


#Preview{
    AddPhotoPrompt()
}
