//
//  CameraUi.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

import SwiftUI

struct CameraUi: View {
    @StateObject private var camera = CameraService()

    var body: some View {
        ZStack {
            CameraView(service: camera)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Button(action: {
                    camera.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 2)
                        )
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
    }
}


