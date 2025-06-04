//
//  QRCodeEducationLoadingViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

final class QRCodeEducationLoadingViewModel: ObservableObject {
    @Published private(set) var currentItem: QRCodeEducationLoadingItem?

    private let items: [QRCodeEducationLoadingItem]

    init(items: [QRCodeEducationLoadingItem]) {
        self.items = items
    }

    func start() async {
        guard !items.isEmpty else { return }

        for item in items {
            await MainActor.run {
                self.currentItem = item
            }
            try? await Task.sleep(nanoseconds: item.durationInNanoseconds)
        }
    }
}
