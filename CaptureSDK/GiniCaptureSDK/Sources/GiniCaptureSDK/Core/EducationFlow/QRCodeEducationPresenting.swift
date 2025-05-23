//
//  QRCodeEducationable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 A protocol that exposes the completion of a QR code education flow.
 
 This protocol allows external components to await the completion of an
 education animation related to QR code scanning.
 */
public protocol QRCodeEducationPresenting {
    /**
     The currently running QR code education task, if any.
     */
    var educationTask: Task<Void, Never>? { get }
}
