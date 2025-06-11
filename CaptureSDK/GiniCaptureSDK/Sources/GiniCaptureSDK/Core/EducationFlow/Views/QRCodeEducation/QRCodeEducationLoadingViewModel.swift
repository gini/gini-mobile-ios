//
//  QRCodeEducationLoadingViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

/*
 ViewModel responsible for managing the sequential display of loading items
 during the QR code education animation.
 */
final class QRCodeEducationLoadingViewModel {
    @Published private(set) var currentItem: QRCodeEducationLoadingItem?

    private let items: [QRCodeEducationLoadingItem]

    init(items: [QRCodeEducationLoadingItem]) {
        self.items = items
    }

    /*
     Starts the animation and calls `completion` once all items are shown.
     Each item is set on the main thread and displayed for its specified duration.
     If no items are available, the method returns immediately.
     */
    func start(completion: (() -> Void)? = nil) {
        Task {
            guard !items.isEmpty else {
                completion?()
                return
            }

            for item in items {
                await MainActor.run {
                    self.currentItem = item
                }
                try? await Task.sleep(nanoseconds: item.durationInNanoseconds)
            }

            completion?()
        }
    }
}
