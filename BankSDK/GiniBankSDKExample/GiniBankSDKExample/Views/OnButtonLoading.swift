//
//  OnButtonLoading.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public final class OnButtonLoading: UIActivityIndicatorView, OnButtonLoadingIndicatorAdapter {
    public func startAnimation() {
        self.startAnimating()
    }

    public func stopAnimation() {
        self.stopAnimating()
    }

    public func injectedView() -> UIView {
        self.style = .large
        self.color = .red
        self.startAnimating()

        return self
    }

    public func onDeinit() {
        // Intentionally left empty
    }
}
