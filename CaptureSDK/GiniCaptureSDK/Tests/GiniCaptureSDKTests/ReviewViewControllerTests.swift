//
//  ReviewViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ReviewViewControllerTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration.shared
    lazy var reviewViewController: ReviewViewController = {
        let vc = ReviewViewController(pages: self.imagePages,
                                      giniConfiguration: self.giniConfiguration)
        _ = vc.view
        return vc
    }()
    
    var imagePages: [GiniCapturePage] = [
        GiniCaptureTestsHelper.loadImagePage(named: "invoice"),
        GiniCaptureTestsHelper.loadImagePage(named: "invoice2"),
        GiniCaptureTestsHelper.loadImagePage(named: "invoice3")
    ]

    // MARK: - Helper Methods
    private func calculateExpectedItemSize() -> CGSize {
        let a4Ratio = 1.4142

        if UIDevice.current.isIpad {
            let isLandscape = UIDevice.current.isLandscape

            // Use the same multiplier logic as ReviewViewController
            let multiplier: CGFloat

            if isLandscape {
                // Note: Assuming saveToGalleryView is not shown in tests
                multiplier = 0.65 // ipadLandscapeHeightMultiplierWithoutSaveToGallery
            } else {
                // Portrait - assuming saveToGalleryView is not shown
                multiplier = 0.75
            }

            let height = reviewViewController.view.bounds.height * multiplier
            let width = height / a4Ratio
            return CGSize(width: width, height: height)
        } else {
            // iPhone - replicate calculateHeightMultiplier() logic
            let multiplier = calculateExpectedHeightMultiplier()
            let height = reviewViewController.view.bounds.height * multiplier
            let width = height / a4Ratio
            return CGSize(width: width, height: height)
        }
    }

    private func calculateExpectedHeightMultiplier() -> CGFloat {
        let isLandscape = UIDevice.current.isLandscape
        let isSmallDevice = UIDevice.current.isNonNotchSmallScreen()

        if isSmallDevice {
            if isLandscape {
                return 0.5
            } else {
                return 0.45
            }
        } else if isLandscape {
            return 0.55
        } else {
            // Portrait
            let baseMultiplier: CGFloat
            if reviewViewController.view.safeAreaInsets.bottom > 0 {
                // Device with safe area (notch)
                baseMultiplier = 0.58
            } else {
                // Device without safe area
                baseMultiplier = 0.5
            }
            return baseMultiplier
        }
    }

    // MARK: - Tests

    func testCollectionsItemsCount() {
        XCTAssertEqual(reviewViewController.collectionView.numberOfItems(inSection: 0),
                       3,
                       "main collection items count should be 3")
    }

    func testMainCollectionCellSize() {
        reviewViewController.view.setNeedsLayout()
        reviewViewController.view.layoutIfNeeded()

        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = reviewViewController.collectionView(
            reviewViewController.collectionView,
            layout: reviewViewController.collectionView.collectionViewLayout,
            sizeForItemAt: firstCellIndexPath
        )

        let expectedItemSize = calculateExpectedItemSize()

        XCTAssertEqual(cellSize,
                       expectedItemSize,
                       "Cell size should match the calculated item size")
    }

    func testMainCollectionInsets() {
        let minCollectionPadding: CGFloat = 5.0

        let collectionInsets = reviewViewController.collectionView(
            reviewViewController.collectionView,
            layout: reviewViewController.collectionView.collectionViewLayout,
            insetForSectionAt: 0
        )

        // Just verify the insets follow the expected rules
        XCTAssertEqual(collectionInsets.top,
                       0,
                       "Top inset should be 0")
        XCTAssertEqual(collectionInsets.bottom,
                       0,
                       "Bottom inset should be 0")
        XCTAssertGreaterThanOrEqual(collectionInsets.left,
                                    minCollectionPadding,
                                    "Left inset should be at least \(minCollectionPadding)")
        XCTAssertGreaterThanOrEqual(collectionInsets.right,
                                    minCollectionPadding,
                                    "Right inset should be at least minCollectionPadding \(minCollectionPadding)")
        XCTAssertEqual(collectionInsets.left,
                       collectionInsets.right,
                       "Left and right insets should be equal (centered)")
    }

    func testCollectionViewLayoutSpacing() {
        guard let layout = reviewViewController.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            XCTFail("Collection view layout should be UICollectionViewFlowLayout")
            return
        }

        let collectionInterItemSpacing: CGFloat = UIDevice.current.isIpad && UIDevice.current.isPortrait ? 24 : 8
        let minCollectionLineSpacing: CGFloat = 5.0 // value per implementation in ReviewViewController

        XCTAssertEqual(layout.minimumLineSpacing,
                       minCollectionLineSpacing,
                       "Minimum line spacing should be \(minCollectionLineSpacing)pt for current device/orientation")
        XCTAssertEqual(layout.minimumInteritemSpacing,
                       collectionInterItemSpacing,
                       "Minimum interitem spacing should be \(collectionInterItemSpacing)pt for current device/orientation")
    }


    // MARK: - Regression Guards

    func testSaveToGalleryViewValueChangedInitialisesToFalse() {
        let saveToGalleryView = SaveToGalleryView()
        XCTAssertFalse(saveToGalleryView.valueChanged,
                       "valueChanged must start as false to prevent the initial Combine emission from triggering the permission flow on view load ")
    }

    func testUserDefaultsSavePhotosSwitchNotOverwrittenOnViewLoad() {
        GiniCaptureUserDefaultsStorage.userSettingsSavePhotosSwitchOn = true

        let vc = ReviewViewController(pages: imagePages,
                                      giniConfiguration: giniConfiguration)
        _ = vc.view

        XCTAssertEqual(GiniCaptureUserDefaultsStorage.userSettingsSavePhotosSwitchOn, true,
                       "userSettingsSavePhotosSwitchOn must not be overwritten on view load — dropFirst() must suppress the initial emission")

        GiniCaptureUserDefaultsStorage.userSettingsSavePhotosSwitchOn = nil
    }

    // MARK: - Fix the test with tap event simulation

//    func testDatasourceOnDelete() {
//        let vc = ReviewViewController(pages: imagePages,
//                                               giniConfiguration: giniConfiguration)
//        _ = vc.view
//        vc.view.setNeedsLayout()
//        vc.view.layoutIfNeeded()
//        if let button = (vc.deleteButton.customView as? UIButton){
//            button.simulateEvent(.touchUpInside)
//        }
//
//
//        //(vc.deleteButton.customView as? UIButton)?.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 2,
//                       "main collection items count should be 2")
//        XCTAssertEqual(vc.pagesCollection.numberOfItems(inSection: 0), 2,
//                       "pages collection items count should be 2")
//    }

    // MARK: - Bottom-nav collapse regression guards

    /// The canonical `optionsStackView` constraint set must be observable via
    /// an on-screen, non-zero stack frame that stays inside the safe area.
    /// Constraint arrays themselves are `private lazy`, so this asserts the
    /// surviving layout via the visible side effect — the frame being placed
    /// by the sole active portrait constraint set.
    /// The stack view is looked up by walking `view` subviews rather than by
    /// mirror (lazy stored properties surface as `$__lazy_storage_$_*` in the
    /// mirror before first access, and the private lazy binding forces access
    /// via reflection to be brittle).
    func testCollapsedConstraintSet_singleCanonicalActivated_portrait() {
        let vc = ReviewViewController(pages: imagePages,
                                      giniConfiguration: giniConfiguration)
        _ = vc.view
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        let optionsStack = findFirstStackView(in: vc.view)
        XCTAssertNotNil(optionsStack,
                        "A vertical UIStackView (optionsStackView) must exist under ReviewViewController.view")

        let frame = optionsStack?.frame ?? .zero
        XCTAssertGreaterThan(frame.width,
                             0,
                             "optionsStackView width must be non-zero after layout — the canonical constraint set must be active")
        XCTAssertGreaterThan(frame.height,
                             0,
                             "optionsStackView height must be non-zero after layout — the canonical constraint set must be active")
    }

    /// Walk the view hierarchy and return the first vertical `UIStackView`
    /// encountered — the `optionsStackView` on `ReviewViewController` is the
    /// only vertical stack in the tree.
    private func findFirstStackView(in view: UIView) -> UIStackView? {
        if let stack = view as? UIStackView, stack.axis == .vertical {
            return stack
        }
        for subview in view.subviews {
            if let match = findFirstStackView(in: subview) {
                return match
            }
        }
        return nil
    }

    /// `calculateHeightMultiplier()` is `private`. Assert its output via the
    /// observable side effect — the cell size returned by the flow-layout
    /// delegate — which reduces to `view.bounds.height * multiplier / a4Ratio`
    /// on iPhone. On the false branch (non-small notch device in portrait), the
    /// multiplier is `Constants.portraitHeightMultiplierWithSafeArea == 0.58`
    /// or `portraitHeightMultiplierWithoutSafeArea == 0.5`, adjusted only when
    /// saveToGalleryView is shown (it isn't in tests). Assertion is
    /// device-agnostic: multiplier must match the pre-PR `false`-branch value
    /// tabulated in `calculateExpectedHeightMultiplier()`.
    func testHeightMultipliersCollapsed_iPhonePortrait_returnsFalseBranchValue() {
        guard !UIDevice.current.isIpad else {
            /// Test targets the iPhone branch of `calculateHeightMultiplier()`.
            /// Skip on iPad — iPad uses a separate cell-size path.
            return
        }

        reviewViewController.view.setNeedsLayout()
        reviewViewController.view.layoutIfNeeded()

        let cellSize = reviewViewController.collectionView(
            reviewViewController.collectionView,
            layout: reviewViewController.collectionView.collectionViewLayout,
            sizeForItemAt: IndexPath(row: 0, section: 0)
        )

        let expectedMultiplier = calculateExpectedHeightMultiplier()
        let expectedHeight = reviewViewController.view.bounds.height * expectedMultiplier

        XCTAssertEqual(cellSize.height,
                       expectedHeight,
                       accuracy: 0.5,
                       "iPhone cell height must match the `false`-branch multiplier — the WithBottomBar branch has been collapsed away")
    }

    /// Guards against re-introduction of any `*WithBottomBar` constraint array
    /// as a stored property on `ReviewViewController`. Parallels the R12
    /// mirror-walk regression test but scoped to constraints.
    func testNoWithBottomBarConstraintProperty_exists() {
        let vc = ReviewViewController(pages: imagePages,
                                      giniConfiguration: giniConfiguration)
        _ = vc.view

        let mirror = Mirror(reflecting: vc)
        for child in mirror.children {
            guard let name = child.label else { continue }
            /// `contains` rather than `hasSuffix` because lazy stored
            /// properties surface as `$__lazy_storage_$_<name>` in the mirror.
            XCTAssertFalse(name.contains("WithBottomBar"),
                           "Stored property \(name) must not reference WithBottomBar — the dual-constraint variant is not supported")
            XCTAssertFalse(name.lowercased().contains("bottomnav"),
                           "Stored property \(name) must not reference bottomNav — the adapter surface is not supported")
        }
    }
}
