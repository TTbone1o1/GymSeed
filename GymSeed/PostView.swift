//
//  PostView.swift
//  GymSeed
//
//  Created by Abraham May on 8/23/25.
//

import SwiftUI

struct PostView: View {
    @Binding var caption: String
    
    var body: some View {
        Button {

        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
        }

        TextField( "Write a caption", text: $caption )
            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 12)
                            .frame(width: 270)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        Button {

        } label: {
            Text("Post")
        }
        .fontWeight(.semibold)
        .frame(width: 270, height: 76)
        .background(Color.white)
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 37, style: .continuous))
        .shadow(radius: 2, y: 1)
    }
}

#Preview {
    PostView(caption: .constant(""))
}
