//
//  QREngagementViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

public class QREngagementViewModel {
    public let steps: [QREngagementStep] = [.first, .second, .third]

    public private(set) var currentIndex: Int = 0 {
        didSet {
            onPageChange?(currentIndex)
        }
    }

    public var onPageChange: ((Int) -> Void)?

    public init() { }

    public func moveToNext() {
        guard currentIndex < steps.count - 1 else { return }
        currentIndex += 1
    }

    public func moveToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    public func setPage(index: Int) {
        guard index >= 0 && index < steps.count else { return }
        currentIndex = index
    }
}
