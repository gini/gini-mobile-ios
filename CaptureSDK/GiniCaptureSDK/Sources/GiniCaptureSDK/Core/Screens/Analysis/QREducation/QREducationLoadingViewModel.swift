//
//  QREducationLoadingViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

final class QREducationLoadingViewModel: ObservableObject {
    @Published private(set) var currentItem: QREducationLoadingItem?

    private let items: [QREducationLoadingItem]

    init(items: [QREducationLoadingItem]) {
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
