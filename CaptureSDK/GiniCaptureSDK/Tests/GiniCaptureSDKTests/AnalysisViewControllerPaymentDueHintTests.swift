//
//  AnalysisViewControllerPaymentDueHintTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

// MARK: - Mock

private final class MockCustomLoadingIndicator: CustomLoadingIndicatorAdapter {
    func onDeinit() {
        // Intentionally left empty
    }
    
    private let _view = UIView()
    private(set) var stopAnimationCalled = false

    func injectedView() -> UIView { _view }
    func startAnimation() {
        // Intentionally left empty
    }
    func stopAnimation() { stopAnimationCalled = true }
}

// MARK: - Suite

@Suite("AnalysisViewController Payment Due Hint")
struct AnalysisViewControllerPaymentDueHintTests {

    private func makeImportedImageVC(config: GiniConfiguration) -> AnalysisViewController {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        guard let data = image.jpegData(compressionQuality: 0.2) else {
            #expect(Bool(false), "Failed to create JPEG data from invoice image")
            let document = GiniImageDocument(data: Data(), imageSource: .external)
            return AnalysisViewController(document: document, giniConfiguration: config)
        }
        let document = GiniImageDocument(data: data, imageSource: .external)
        return AnalysisViewController(document: document, giniConfiguration: config)
    }

    @Test("Custom indicator is stopped and its view removed when hint is shown")
    @MainActor func customLoadingIndicatorStoppedWhenHintShown() {
        let mockIndicator = MockCustomLoadingIndicator()
        let config = GiniConfiguration()
        config.fileImportSupportedTypes = .pdf
        config.customLoadingIndicator = mockIndicator
        let sut = makeImportedImageVC(config: config)
        _ = sut.view

        sut.handlePaymentDueDate("13.06.2026")

        #expect(mockIndicator.stopAnimationCalled, "Custom indicator should be stopped")
        #expect(mockIndicator.injectedView().superview == nil, "Custom indicator view should be removed from hierarchy")
    }

    @Test("Default activity indicator is not animating when hint is shown")
    @MainActor func defaultActivityIndicatorStoppedWhenHintShown() {
        let config = GiniConfiguration()
        config.fileImportSupportedTypes = .pdf
        let sut = makeImportedImageVC(config: config)
        _ = sut.view

        sut.handlePaymentDueDate("13.06.2026")

        let animating = allActivityIndicators(in: sut.view).filter { $0.isAnimating }
        #expect(animating.isEmpty, "No activity indicator should be animating after hint is shown")
    }

    @Test("PaymentDueHintView and DismissMessageView are present after hint is shown")
    @MainActor func hintAndDismissViewsPresentAfterHandlePaymentDueDate() {
        let config = GiniConfiguration()
        config.fileImportSupportedTypes = .pdf
        let sut = makeImportedImageVC(config: config)
        _ = sut.view

        sut.handlePaymentDueDate("13.06.2026")

        #expect(contains(type: PaymentDueHintView.self, in: sut.view), "PaymentDueHintView should be in the view hierarchy")
        #expect(contains(type: DismissMessageView.self, in: sut.view), "DismissMessageView should be in the view hierarchy")
    }

    // MARK: - Helpers

    private func allActivityIndicators(in view: UIView) -> [UIActivityIndicatorView] {
        var result = view.subviews.compactMap { $0 as? UIActivityIndicatorView }
        result += view.subviews.flatMap { allActivityIndicators(in: $0) }
        return result
    }

    private func contains<T: UIView>(type: T.Type, in view: UIView) -> Bool {
        if view is T { return true }
        return view.subviews.contains { contains(type: type, in: $0) }
    }
}
