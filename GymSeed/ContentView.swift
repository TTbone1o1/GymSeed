//
//  ContentView.swift
//  GymSeed
//
//  Created by Abraham may on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            ZStack {
                  // 8 rectangles with different offsets]
                PhotoCard(imageName: "image1", offset: CGSize(width: -140, height: 10), rotation: -20)
                PhotoCard(imageName: "image2", offset: CGSize(width: -270, height: 150), rotation: -20)
                PhotoCard(imageName: "image3", offset: CGSize(width: -75, height: -150), rotation: 20)
                PhotoCard(imageName: "image8", offset: CGSize(width: -125, height: -175), rotation: -15)
                PhotoCard(imageName: "image5", offset: CGSize(width: 220, height: 140), rotation: 5)
                PhotoCard(imageName: "image6", offset: CGSize(width: 140, height: 50), rotation: -15)
                PhotoCard(imageName: "image7", offset: CGSize(width: 5, height: 35), rotation: 15)
                PhotoCard(imageName: "image4", offset: CGSize(width: 60, height: 40), rotation: -15)
                PhotoCard(imageName: "image9", offset: CGSize(width: 100, height: -170), rotation: 5)
              }
              .padding(.bottom, 50)

            Text("GymSeed")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Spacer()

            AddPhotoPrompt()
            .padding(.bottom, 40)
        }
        .padding([.horizontal, .bottom])          // keep side + bottom padding
                .ignoresSafeArea(.container, edges: .top)
    }
}


#Preview {
    ContentView()
}
