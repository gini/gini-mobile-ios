//
//  EmptyScrollViewTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers EmptyScrollView: initial setup, content subview hosting,
//  the internal constraint layout, and the @Published size updates
//  driven by contentSize KVO.

import Testing
import UIKit
import Combine
@testable import GiniUtilites

@Suite("EmptyScrollView — content hosting and size publishing")
@MainActor
struct EmptyScrollViewTests {

    /**
     Waits for one main-queue turn so values delivered through
     `.receive(on: DispatchQueue.main)` have been processed. The KVO fires
     synchronously when `contentSize` is set, so a single later-enqueued hop
     on the same serial queue is a deterministic ordering guarantee.
     */
    private func waitForMainQueueTurn() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                continuation.resume()
            }
        }
    }

    @Test("Initialization disables autoresizing translation and installs the content view")
    func initializationSetsUpContentView() throws {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        #expect(scrollView.translatesAutoresizingMaskIntoConstraints == false)

        let contentView = try #require(scrollView.subviews.first)
        #expect(contentView.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("Content view is pinned to the content layout guide and matches the frame width")
    func contentViewIsPinnedWithFiveActiveConstraints() throws {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let contentView = try #require(scrollView.subviews.first)

        let contentViewConstraints = scrollView.constraints.filter { $0.firstItem === contentView }

        #expect(contentViewConstraints.count == 5)
        #expect(Set(contentViewConstraints.map(\.firstAttribute)) == [.top, .bottom, .leading, .trailing, .width])
        for constraint in contentViewConstraints {
            #expect(constraint.isActive == true)
        }
    }

    @Test("addContentSubview adds the view to the content view, not the scroll view")
    func addContentSubviewAddsToContentView() throws {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let contentView = try #require(scrollView.subviews.first)
        let subview = UIView()

        scrollView.addContentSubview(subview)

        #expect(subview.superview === contentView)
        #expect(subview.superview !== scrollView)
    }

    @Test("size starts at zero")
    func sizeStartsAtZero() {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        #expect(scrollView.size == .zero)
    }

    @Test("Setting a contentSize with positive height publishes the new size")
    func contentSizeWithPositiveHeightPublishesSize() async {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let newContentSize = CGSize(width: 320, height: 600)

        scrollView.contentSize = newContentSize
        await waitForMainQueueTurn()

        #expect(scrollView.size == newContentSize)
    }

    @Test("Setting a contentSize with zero height is filtered out and does not publish")
    func contentSizeWithZeroHeightIsFilteredOut() async {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        scrollView.contentSize = CGSize(width: 100, height: 0)
        await waitForMainQueueTurn()

        #expect(scrollView.size == .zero)
    }

    @Test("The latest contentSize wins when multiple updates are applied")
    func latestContentSizeWins() async {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let finalContentSize = CGSize(width: 320, height: 900)

        scrollView.contentSize = CGSize(width: 320, height: 300)
        scrollView.contentSize = finalContentSize
        await waitForMainQueueTurn()

        #expect(scrollView.size == finalContentSize)
    }

    @Test("Size changes are observable through the published projection")
    func sizeChangesAreObservableThroughPublisher() async {
        let scrollView = EmptyScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let expectedContentSize = CGSize(width: 320, height: 500)

        await confirmation("Publisher delivers the non-zero size") { confirm in
            var cancellables = Set<AnyCancellable>()
            scrollView.$size
                .filter { $0 != .zero }
                .sink { publishedSize in
                    #expect(publishedSize == expectedContentSize)
                    confirm()
                }
                .store(in: &cancellables)

            scrollView.contentSize = expectedContentSize
            await waitForMainQueueTurn()
        }
    }
}
