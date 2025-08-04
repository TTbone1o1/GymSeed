//
//  OnboardingUserName.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct OnboardingUserName: View {
    @Binding var name: String

    var body: some View {
        VStack(spacing: 24) {
            Text("What should we\ncall you?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .frame(width: 250, alignment: .leading)
            
            TextField("Enter your name", text: $name)
                .padding()
                .frame(width: 250, height: 65)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
}


#Preview {
    PreviewUserInput("") { nameBinding in
        OnboardingUserName(name: nameBinding)
    }
}
