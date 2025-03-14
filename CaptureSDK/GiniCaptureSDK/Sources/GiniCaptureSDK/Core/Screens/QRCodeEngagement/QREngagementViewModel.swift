//
//  QREngagementViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

// TODO: remove public after tests & integration
public class QREngagementViewModel {
    let steps: [QREngagementStep] = [.first, .second, .third]

    private(set) var currentIndex: Int = 0 {
        didSet {
            onPageChange?(currentIndex)
        }
    }

    var onPageChange: ((Int) -> Void)?

    public init() { }

    func moveToNext() {
        guard currentIndex < steps.count - 1 else { return }
        currentIndex += 1
    }

    func moveToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func setPage(index: Int) {
        guard index >= 0 && index < steps.count else { return }
        currentIndex = index
    }
}
