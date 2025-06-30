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

    /**
     Starts the sequential display of all educational animation items.

     - Ensures each item is presented on the main thread by assigning it to `currentItem`.
     - Waits asynchronously for the specified duration of each item before proceeding to the next.
     - If no items are available, the method exits immediately without performing any actions.

     This method is `async` and can be awaited. It is intended to be called inside an `async` context,
     such as a `Task` block, to manage the lifecycle of the animation flow.
     */
    func start() async {
        guard !items.isEmpty else {
            return
        }

        for item in items {
            await MainActor.run {
                self.currentItem = item
            }
            try? await Task.sleep(nanoseconds: item.durationInNanoseconds)
        }
    }
}
