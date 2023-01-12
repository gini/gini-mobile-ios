//
//  CameraPreviewView.swift
//  GiniCapture
//
//  Created by Peter Pult / Nikola Sobadjiev on 14/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var session: AVCaptureSession {
        get {
            return (self.layer as? AVCaptureVideoPreviewLayer)!.session!
        }
        set(newSession) {
            if let captureLayer = layer as? AVCaptureVideoPreviewLayer {
                captureLayer.videoGravity = .resizeAspectFill
            }
            (self.layer as? AVCaptureVideoPreviewLayer)!.session = newSession
        }
    }
}
