//
//  CameraView.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

import SwiftUI
import AVFoundation

final class CameraContainerView: UIView {
    let previewLayer = AVCaptureVideoPreviewLayer()
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

struct CameraView: UIViewRepresentable {
    @ObservedObject var service: CameraService

    func makeUIView(context: Context) -> CameraContainerView {
        let view = CameraContainerView()
        if let pl = service.previewLayer {
            view.previewLayer.session = pl.session
            view.previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(view.previewLayer)
        }
        return view
    }

    func updateUIView(_ uiView: CameraContainerView, context: Context) {}
}

