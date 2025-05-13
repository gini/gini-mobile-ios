//
//  QRCodeEducationable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

public protocol QRCodeEducationable {
    var educationTask: Task<Void, Never>? { get }
}
