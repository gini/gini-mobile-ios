//
//  CameraViewController+QRCodeEducationPresenting.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

extension CameraViewController: QRCodeEducationPresenting {
    /**
     The currently running QR code education task, if any.
     */
    public var educationTask: Task<Void, Never>? {
        qrCodeOverLay.currentEducationTask
    }
}
