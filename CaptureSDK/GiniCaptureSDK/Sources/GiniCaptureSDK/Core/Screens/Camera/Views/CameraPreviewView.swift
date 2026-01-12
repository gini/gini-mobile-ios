//
//  CameraPreviewView.swift
//  GiniCapture
//
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("""
                       Expected `AVCaptureVideoPreviewLayer` type for layer.
                       Check PreviewView.layerClass implementation.
                       """)
        }

        return layer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var session: AVCaptureSession {
        get {
            return videoPreviewLayer.session!
        }
        set(newSession) {
            videoPreviewLayer.session = newSession
        }
    }
}
