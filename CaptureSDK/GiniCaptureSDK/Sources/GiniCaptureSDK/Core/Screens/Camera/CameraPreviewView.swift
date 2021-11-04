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
    
    let frameColor = UIColor(white: 0.0, alpha: 0.7)
    let guideLineLength: CGFloat = 50.0
    let guideLineWidth: CGFloat = 2.0
    /// the size of the guides compared to the size of the whole view
    /// 0.9 = 90% of the view
    let guideLineSize: CGFloat = 0.9
    fileprivate(set) var guideColor = UIColor.white
    fileprivate(set) var ratio: CGFloat = 21.0 / 31.0 // A4 by default
    fileprivate(set) var guidesLayer: CAShapeLayer?
    fileprivate(set) var frameLayer: CAShapeLayer?
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var session: AVCaptureSession {
        get {
            return (self.layer as? AVCaptureVideoPreviewLayer)!.session!
        }
        set(newSession) {
            (self.layer as? AVCaptureVideoPreviewLayer)!.session = newSession
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionViews()
    }
    
    func positionViews() {
        positionGuides()
        positionFrame()
    }
    
}

extension CameraPreviewView {
    
    func drawGuides(withColor color: UIColor) {
        guideColor = color
        createGuides()
        createGrayFrame()
    }
    
    fileprivate func createGuides() {
        let rectLayer = CAShapeLayer()
        styleLayer(rectLayer)
        layer.addSublayer(rectLayer)
        guidesLayer = rectLayer
    }
    
    fileprivate func createGrayFrame() {
        let grayFrame = CAShapeLayer()
        grayFrame.fillColor = frameColor.cgColor
        grayFrame.lineWidth = 0
        layer.addSublayer(grayFrame)
        frameLayer = grayFrame
    }
    
    fileprivate func positionGuides() {
        guard let guides = guidesLayer else {
            return
        }
        // get a size that's a close to guideLineSize as possible, while still respecting the
        // ratio of a standard A4 piece of paper
        guides.frame = biggestA4SizeRect()
        guides.position = center
        guides.path = guidePath(size: guides.frame.size)
    }
    
    fileprivate func positionFrame() {
        guard let grayFrame = frameLayer else {
            return
        }
        // The frame is as big as the guides
        var innerRect = biggestA4SizeRect()
        // However, in order for them to not overlap, the frame needs to get a little bigger
        innerRect.origin.x = ((frame.width - innerRect.width) / 2.0) - (guideLineWidth / 2.0)
        innerRect.origin.y = ((frame.height - innerRect.height) / 2.0) - (guideLineWidth / 2.0)
        innerRect.size.width += guideLineWidth
        innerRect.size.height += guideLineWidth
        let cutOut = UIBezierPath(rect: innerRect)
        let path = UIBezierPath(rect: bounds)
        path.append(cutOut.reversing())
        
        grayFrame.path = path.cgPath
        grayFrame.frame = frame
        grayFrame.position = center
    }
    
    fileprivate func biggestA4SizeRect() -> CGRect {
        let wholeFrame = bounds
        let maxWidth = wholeFrame.width * guideLineSize
        let maxHeight = wholeFrame.height * guideLineSize

        if (maxHeight > maxWidth || UIApplication.shared.statusBarOrientation.isPortrait) &&
            maxWidth > maxHeight * ratio {
            return CGRect(x: 0, y: 0, width: maxHeight * ratio, height: maxHeight)
        } else {
            let height: CGFloat
            if maxWidth > maxHeight * ratio {
                // This only happens when the app is on landscape mode and
                // it fills all the window (no SplitMode on iPads).
                // In this case the a4 would be landscape (31.0 / 21.0)
                height = maxWidth * ratio
            } else {
                height = maxWidth / ratio
            }
            return CGRect(x: 0, y: 0, width: maxWidth, height: height)
        }
    }
    
    fileprivate func guidePath(size: CGSize) -> CGPath {
        let guidePath = UIBezierPath()
        
        guidePath.move(to: CGPoint(x: 0.0, y: guideLineLength))
        guidePath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        guidePath.addLine(to: CGPoint(x: guideLineLength, y: 0.0))
        
        guidePath.move(to: CGPoint(x: size.width - guideLineLength, y: 0.0))
        guidePath.addLine(to: CGPoint(x: size.width, y: 0.0))
        guidePath.addLine(to: CGPoint(x: size.width, y: guideLineLength))
        
        guidePath.move(to: CGPoint(x: size.width, y: size.height - guideLineLength))
        guidePath.addLine(to: CGPoint(x: size.width, y: size.height))
        guidePath.addLine(to: CGPoint(x: size.width - guideLineLength, y: size.height))
        
        guidePath.move(to: CGPoint(x: guideLineLength, y: size.height))
        guidePath.addLine(to: CGPoint(x: 0, y: size.height))
        guidePath.addLine(to: CGPoint(x: 0, y: size.height - guideLineLength))
        return guidePath.cgPath
    }
    
    fileprivate func styleLayer(_ layer: CAShapeLayer) {
        layer.strokeColor = guideColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = guideLineWidth
    }
    
}
