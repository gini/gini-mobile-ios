//
//  InfoBottomSheetButtonsViewModelTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniCaptureSDK

@Suite("InfoBottomSheetButtonsViewModel")
struct InfoBottomSheetButtonsViewModelTests {

    @Test("Titles reflect the injected buttons")
    func titlesReflectInjectedButtons() {
        let sut = InfoBottomSheetButtonsViewModel(.init(title: "Primary", action: {}),
                                                  .init(title: "Secondary", action: {}))

        #expect(sut.primaryTitle == "Primary")
        #expect(sut.secondaryTitle == "Secondary")
    }

    @Test("Titles are nil when no buttons are injected")
    func titlesAreNilWithoutButtons() {
        let sut = InfoBottomSheetButtonsViewModel()

        #expect(sut.primaryTitle == nil)
        #expect(sut.secondaryTitle == nil)
    }

    @Test("didPressPrimary invokes only the primary action")
    func didPressPrimaryInvokesPrimaryAction() {
        var primaryCallCount = 0
        var secondaryCallCount = 0
        let sut = InfoBottomSheetButtonsViewModel(.init(title: "Primary", action: { primaryCallCount += 1 }),
                                                  .init(title: "Secondary", action: { secondaryCallCount += 1 }))

        sut.didPressPrimary()

        #expect(primaryCallCount == 1)
        #expect(secondaryCallCount == 0)
    }

    @Test("didPressSecondary invokes only the secondary action")
    func didPressSecondaryInvokesSecondaryAction() {
        var primaryCallCount = 0
        var secondaryCallCount = 0
        let sut = InfoBottomSheetButtonsViewModel(.init(title: "Primary", action: { primaryCallCount += 1 }),
                                                  .init(title: "Secondary", action: { secondaryCallCount += 1 }))

        sut.didPressSecondary()

        #expect(primaryCallCount == 0)
        #expect(secondaryCallCount == 1)
    }

    @Test("Pressing without configured buttons does not crash")
    func pressingWithoutButtonsIsNoOp() {
        let sut = InfoBottomSheetButtonsViewModel()

        sut.didPressPrimary()
        sut.didPressSecondary()

        #expect(sut.primaryTitle == nil)
        #expect(sut.secondaryTitle == nil)
    }
}
