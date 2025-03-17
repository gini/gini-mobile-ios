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

    public init() {
        // empty init
    }

    func setPage(index: Int) {
        guard index >= 0 && index < steps.count else { return }
        currentIndex = index
    }
}
