//
//  CameraView.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var service: CameraService

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        if let previewLayer = service.previewLayer {
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

