//
//  CircleBlur.swift
//  GymSeed
//
//  Created by Abraham May on 9/28/25.
//

import SwiftUI

struct CircleBlur: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("CirclePurple"))
                .frame(width: 550, height: 550)
                .blur(radius: 40)   // strong blur

            Circle()
                .fill(Color("CircleBlue"))
                .frame(width: 370, height: 370)
                .blur(radius: 40)    // slightly less blur
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea() // let it flow under safe areas
    }
}

#Preview {
    CircleBlur()
}
