//
//  CameraViewController+QRCodeEducationable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

extension CameraViewController: QRCodeEducationable {
    public var educationTask: Task<Void, Never>? {
        qrCodeOverLay.currentEducationTask
    }
}
