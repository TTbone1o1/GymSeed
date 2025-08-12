//
//  CameraService.swift
//  GymSeed
//
//  Created by Abraham may on 8/4/25.
//

import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "cameraQueue")

    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()

        // Set high quality
        session.sessionPreset = .photo

        // Add input
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        session.addInput(input)

        // Add output
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        session.commitConfiguration()

        // Create preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
    }

    func start() {
        queue.async {
            self.session.startRunning()
        }
    }

    func stop() {
        queue.async {
            self.session.stopRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()

        if output.isHighResolutionCaptureEnabled {
            settings.isHighResolutionPhotoEnabled = true
        }

        switch output.maxPhotoQualityPrioritization {
        case .quality:  settings.photoQualityPrioritization = .quality
        case .balanced: settings.photoQualityPrioritization = .balanced
        case .speed:    settings.photoQualityPrioritization = .speed
        @unknown default: settings.photoQualityPrioritization = .balanced
        }

        output.capturePhoto(with: settings, delegate: self)
    }



    // Save captured image
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

