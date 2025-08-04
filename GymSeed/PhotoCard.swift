//
//  Photocard.swift
//  GymSeed
//
//  Created by Abraham may on 8/3/25.
//

import SwiftUI

struct PhotoCard: View {
    let imageName: String
    let offset: CGSize
    let rotation: Double
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 210)
            .clipped()
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.25), radius: 14.7, x: 3, y: 4)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    PhotoCard(imageName: "image1", offset: CGSize(width: 0, height: 0), rotation: 0)
}
