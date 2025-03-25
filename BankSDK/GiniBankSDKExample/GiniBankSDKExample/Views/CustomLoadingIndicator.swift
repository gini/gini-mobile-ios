//
//  CustomLoadingIndicator.swift
//  GiniCaptureSDKExample
//
//  Created by David Vizaknai on 14.09.2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public final class CustomLoadingIndicator: UIActivityIndicatorView, CustomLoadingIndicatorAdapter {
    public func startAnimation() {
        self.startAnimating()
    }

    public func stopAnimation() {
        self.stopAnimating()
    }

    public func injectedView() -> UIView {
        self.style = .large
        self.color = .blue
        self.startAnimating()

        return self
    }

    public func onDeinit() {
    }
}

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

    }
}
