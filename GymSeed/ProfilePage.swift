//
//  ProfilePage.swift
//  GymSeed
//
//  Created by Abraham may on 8/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePage: View {
    var body: some View {
        VStack {
            OnboardingUploadProfile(didUpload: .constant(false))
                .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
        }
        .padding(.top, 50)
    }
}

#Preview {
    ProfilePage()
}
