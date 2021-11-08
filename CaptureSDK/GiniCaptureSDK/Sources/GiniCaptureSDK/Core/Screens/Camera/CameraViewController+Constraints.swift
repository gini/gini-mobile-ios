//
//  CameraViewController+Constraints.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

extension CameraViewController {
    func addConstraints() {
        addPreviewViewConstraints()
        addControlsViewConstraints()
    }
    
    fileprivate func addPreviewViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: cameraPreviewViewController.view, attr: .top, relatedBy: .equal,
                               to: self.view, attr: .top)
            Constraints.active(item: cameraPreviewViewController.view, attr: .bottom, relatedBy: .equal,
                               to: self.view, attr: .bottom)
            Constraints.active(item: cameraPreviewViewController.view, attr: .leading, relatedBy: .equal,
                               to: self.view, attr: .leading)
            Constraints.active(item: cameraPreviewViewController.view, attr: .trailing, relatedBy: .equal,
                               to: cameraButtonsViewController.view, attr: .leading)
        } else {
            // lower priority constraints - will make the preview "want" to get bigger
            Constraints.active(item: cameraPreviewViewController.view, attr: .top, relatedBy: .equal,
                               to: self.view, attr: .top)
            Constraints.active(item: cameraPreviewViewController.view, attr: .leading, relatedBy: .equal,
                               to: self.view, attr: .leading)
            Constraints.active(item: cameraPreviewViewController.view, attr: .trailing, relatedBy: .equal,
                               to: self.view, attr: .trailing)
            Constraints.active(item: cameraPreviewViewController.view, attr: .bottom, relatedBy: .equal,
                               to: cameraButtonsViewController.view, attr: .top)
        }
    }
    
    fileprivate func addControlsViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: cameraButtonsViewController.view, attr: .width, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute,
                               constant: 102)
            Constraints.active(item: cameraButtonsViewController.view, attr: .top, relatedBy: .equal,
                               to: self.view,
                               attr: .top)
            Constraints.active(item: cameraButtonsViewController.view, attr: .trailing, relatedBy: .equal,
                               to: self.view,
                               attr: .trailing)
            Constraints.active(item: cameraButtonsViewController.view, attr: .bottom, relatedBy: .equal,
                               to: self.view,
                               attr: .bottom)
            Constraints.active(item: cameraButtonsViewController.view, attr: .leading, relatedBy: .equal,
                               to: cameraPreviewViewController.view, attr: .trailing, priority: 750)
        } else {
            Constraints.active(item: cameraButtonsViewController.view, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute,
                               constant: 102)
            Constraints.active(item: cameraButtonsViewController.view, attr: .top, relatedBy: .equal,
                               to: cameraPreviewViewController.view,
                               attr: .bottom)
            Constraints.active(item: cameraButtonsViewController.view, attr: .bottom, relatedBy: .equal,
                               to: view.safeAreaLayoutGuide,
                               attr: .bottom)
            Constraints.active(item: cameraButtonsViewController.view, attr: .trailing, relatedBy: .equal,
                               to: self.view, attr: .trailing)
            Constraints.active(item: cameraButtonsViewController.view, attr: .leading, relatedBy: .equal,
                               to: self.view, attr: .leading)
        }
    }
    
}
