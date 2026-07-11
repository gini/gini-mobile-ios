//
//  GiniKeyboardAccessoryInstallerTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import SwiftUI
import UIKit
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

@Suite("GiniKeyboardAccessoryInstaller.Coordinator")
@MainActor
struct GiniKeyboardAccessoryInstallerCoordinatorTests {

    // MARK: - init

    @Test("init stores tint colour and onDone closure")
    func initStoresProperties() {
        var invoked = false
        let sut = makeCoordinator(tintColor: .systemRed, onDone: { invoked = true })

        #expect(sut.doneTintColor == .systemRed)
        sut.onDone()
        #expect(invoked, "onDone stored in init must be callable via the property")
    }

    // MARK: - Delegate callback (giniDoneAccessoryViewDidTapDone)

    @Test("delegate callback invokes onDone once")
    func delegateCallbackInvokesOnDone() {
        var count = 0
        let sut = makeCoordinator(onDone: { count += 1 })

        sut.giniDoneAccessoryViewDidTapDone(GiniDoneAccessoryView(tintColor: .systemBlue))

        #expect(count == 1)
    }

    @Test("delegate callback uses the currently-assigned onDone after mutation")
    func delegateCallbackUsesLatestOnDone() {
        var initial = 0
        var latest = 0
        let sut = makeCoordinator(onDone: { initial += 1 })
        sut.onDone = { latest += 1 }

        sut.giniDoneAccessoryViewDidTapDone(GiniDoneAccessoryView(tintColor: .systemBlue))

        #expect(initial == 0, "the original onDone must not fire after the property is reassigned")
        #expect(latest == 1)
    }

    // MARK: - installIfNeeded

    @Test("installIfNeeded is a no-op when no field is first responder")
    func installNoOpWithoutFirstResponder() {
        let sut = makeCoordinator(currentFirstResponder: { nil })

        sut.installIfNeeded()
        sut.installIfNeeded()
        sut.uninstallIfInstalled()
    }

    @Test("installIfNeeded assigns a GiniDoneAccessoryView with self as delegate")
    func installAssignsAccessoryWithDelegate() throws {
        let field = MockTextField()
        let sut = makeCoordinator(tintColor: .systemBlue, currentFirstResponder: { field })

        sut.installIfNeeded()

        let accessory = try #require(field.inputAccessoryView as? GiniDoneAccessoryView,
                                     "installIfNeeded must set inputAccessoryView to a GiniDoneAccessoryView")
        #expect(accessory.delegate === sut, "the coordinator must own the delegate slot")
        #expect(field.reloadInputViewsCount == 1, "reloadInputViews must be called once after assignment")
    }

    @Test("installIfNeeded is idempotent — re-install on the same field keeps the same accessory and refreshes the tint")
    func installIsIdempotentAndRefreshesTint() throws {
        let field = MockTextField()
        let sut = makeCoordinator(tintColor: .systemBlue, currentFirstResponder: { field })

        sut.installIfNeeded()
        let first = try #require(field.inputAccessoryView as? GiniDoneAccessoryView)

        sut.doneTintColor = .systemRed
        sut.installIfNeeded()

        let second = try #require(field.inputAccessoryView as? GiniDoneAccessoryView)
        #expect(first === second, "the second install on the same field must keep the same accessory instance")
        #expect(field.reloadInputViewsCount == 1, "reloadInputViews must not fire again on idempotent re-install")
    }

    @Test("installIfNeeded replaces an accessory owned by a different delegate")
    func installReplacesForeignAccessory() throws {
        let field = MockTextField()
        let otherOwner = makeCoordinator()
        let foreignAccessory = GiniDoneAccessoryView(tintColor: .systemBlue)
        foreignAccessory.delegate = otherOwner
        field.inputAccessoryView = foreignAccessory

        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()

        let newAccessory = try #require(field.inputAccessoryView as? GiniDoneAccessoryView)
        #expect(newAccessory !== foreignAccessory, "a foreign accessory must be replaced with a self-owned one")
        #expect(newAccessory.delegate === sut)
    }

    // MARK: - uninstallIfInstalled

    @Test("uninstallIfInstalled is a no-op when nothing was ever installed")
    func uninstallNoOpWithoutInstall() {
        let sut = makeCoordinator()
        sut.uninstallIfInstalled()
        sut.uninstallIfInstalled()
    }

    @Test("uninstallIfInstalled clears the accessory and reloads when field is first responder")
    func uninstallClearsAndReloadsWhenFirstResponder() {
        let field = MockTextField()
        field.mockIsFirstResponder = true
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()
        let reloadsAfterInstall = field.reloadInputViewsCount

        sut.uninstallIfInstalled()

        #expect(field.inputAccessoryView == nil, "the accessory must be cleared")
        #expect(field.reloadInputViewsCount == reloadsAfterInstall + 1,
                "reloadInputViews must fire when the field is still first responder")
    }

    @Test("uninstallIfInstalled clears the accessory without reload when field is not first responder")
    func uninstallClearsWithoutReloadWhenNotFirstResponder() {
        let field = MockTextField()
        field.mockIsFirstResponder = false
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()
        let reloadsAfterInstall = field.reloadInputViewsCount

        sut.uninstallIfInstalled()

        #expect(field.inputAccessoryView == nil)
        #expect(field.reloadInputViewsCount == reloadsAfterInstall,
                "reloadInputViews must NOT fire when the field is no longer first responder")
    }

    @Test("uninstallIfInstalled does not touch an accessory replaced by other code")
    func uninstallSkipsForeignAccessory() {
        let field = MockTextField()
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()

        let replacement = UIView()
        field.inputAccessoryView = replacement

        sut.uninstallIfInstalled()

        #expect(field.inputAccessoryView === replacement,
                "uninstall must leave an accessory owned by other code untouched")
    }

    @Test("installIfNeeded reuses the persistent accessory when the field's inputAccessoryView reads back nil")
    func installReusesPersistentAccessoryAfterExternalClear() throws {
        // Simulates the SwiftUI TextField subclass whose `inputAccessoryView` getter returns
        // nil on a subsequent update even after we set it. The idempotent branch will miss,
        // and we must fall through to reusing the persistent instance — not allocate fresh.
        let field = MockTextField()
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()
        let first = try #require(field.inputAccessoryView as? GiniDoneAccessoryView)

        // Simulate the SwiftUI-getter-returns-nil quirk.
        field.inputAccessoryView = nil

        sut.installIfNeeded()
        let second = try #require(field.inputAccessoryView as? GiniDoneAccessoryView)

        #expect(first === second, "the coordinator must reuse its cached accessory, not allocate a fresh one")
    }

    @Test("uninstallIfInstalled clears attachedField so subsequent uninstall is a no-op")
    func uninstallClearsAttachedField() {
        let field = MockTextField()
        field.mockIsFirstResponder = false
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()
        sut.uninstallIfInstalled()
        let reloadsAfterFirstUninstall = field.reloadInputViewsCount

        let stale = GiniDoneAccessoryView(tintColor: .systemBlue)
        stale.delegate = sut
        field.inputAccessoryView = stale

        sut.uninstallIfInstalled()

        #expect(field.inputAccessoryView === stale, "attachedField cleared: uninstall must not walk fields it no longer owns")
        #expect(field.reloadInputViewsCount == reloadsAfterFirstUninstall)
    }

    // MARK: - Static factory + struct integration

    @Test("GiniKeyboardAccessoryInstaller.makeCoordinator seeds tint and onDone")
    func structMakeCoordinatorSeedsProperties() {
        var invoked = false
        let installer = GiniKeyboardAccessoryInstaller(isActive: true,
                                                   doneTintColor: .systemGreen,
                                                   onDone: { invoked = true })

        let coordinator = installer.makeCoordinator()

        #expect(coordinator.doneTintColor == .systemGreen)
        coordinator.onDone()
        #expect(invoked)
    }

    @Test("Hosting the representable exercises makeUIView + updateUIView + default scene walk")
    func hostingExercisesRepresentableLifecycle() async {
        let installer = GiniKeyboardAccessoryInstaller(isActive: true, doneTintColor: .systemBlue, onDone: {})
        let host = UIHostingController(rootView: installer)
        // Put the host in a proper window and force a full layout pass — merely accessing
        // `host.view` doesn't cause SwiftUI to instantiate the representable's UIView.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = host
        window.isHidden = false
        host.beginAppearanceTransition(true, animated: false)
        host.view.layoutIfNeeded()
        host.endAppearanceTransition()
        // Update to isActive == false to also drive the else branch of updateUIView's coordinator.apply.
        host.rootView = GiniKeyboardAccessoryInstaller(isActive: false, doneTintColor: .systemRed, onDone: {})
        host.view.layoutIfNeeded()
        // Yield so the DispatchQueue.main.async body inside apply drains.
        try? await Task.sleep(for: .milliseconds(20))
        window.isHidden = true
    }

    @Test("GiniKeyboardAccessoryInstaller.dismantleUIView triggers uninstall on the coordinator")
    func structDismantleTriggersUninstall() {
        let field = MockTextField()
        field.mockIsFirstResponder = false
        let coordinator = GiniKeyboardAccessoryInstaller.Coordinator(doneTintColor: .systemBlue,
                                                                 onDone: {},
                                                                 currentFirstResponder: { field })
        coordinator.installIfNeeded()

        GiniKeyboardAccessoryInstaller.dismantleUIView(UIView(), coordinator: coordinator)

        #expect(field.inputAccessoryView == nil, "dismantleUIView must uninstall the accessory")
    }

    // MARK: - apply (updateUIView delegate)

    @Test("apply refreshes tint and onDone synchronously, then schedules install async")
    func applySchedulesInstall() async {
        let field = MockTextField()
        var latestCalled = false
        let sut = makeCoordinator(currentFirstResponder: { field })

        sut.apply(isActive: true, doneTintColor: .systemRed, onDone: { latestCalled = true })

        #expect(sut.doneTintColor == .systemRed)
        sut.onDone()
        #expect(latestCalled)
        #expect(field.inputAccessoryView == nil, "install must be deferred to the next runloop")

        try? await Task.sleep(for: .milliseconds(20))

        #expect(field.inputAccessoryView is GiniDoneAccessoryView, "install must run after the async dispatch")
    }

    @Test("apply with isActive == false schedules uninstall async")
    func applySchedulesUninstall() async {
        let field = MockTextField()
        field.mockIsFirstResponder = false
        let sut = makeCoordinator(currentFirstResponder: { field })
        sut.installIfNeeded()

        sut.apply(isActive: false, doneTintColor: .systemBlue, onDone: {})

        try? await Task.sleep(for: .milliseconds(20))

        #expect(field.inputAccessoryView == nil, "uninstall must run after the async dispatch")
    }

    @Test("apply cancels the previous pending work — the latest intent wins")
    func applyCancelsPreviousPendingWork() async {
        // Simulates the SwiftUI update storm: many rapid `apply` calls before the first
        // work item has a chance to fire. Only the LATEST intent must run — the previous
        // pending install must be cancelled, otherwise a stale install would run and
        // then be undone by the queued uninstall, wasting a reloadInputViews call.
        let field = MockTextField()
        field.mockIsFirstResponder = false
        let sut = makeCoordinator(currentFirstResponder: { field })

        sut.apply(isActive: true, doneTintColor: .systemBlue, onDone: {})
        sut.apply(isActive: false, doneTintColor: .systemBlue, onDone: {})

        try? await Task.sleep(for: .milliseconds(20))

        #expect(field.inputAccessoryView == nil,
                "the cancelled install must not have run")
        #expect(field.reloadInputViewsCount == 0,
                "the cancelled install's reloadInputViews must NOT fire")
    }

    @Test("apply captures self weakly — a coordinator released before the async fires is deallocated cleanly")
    func applyCapturesSelfWeakly() async {
        let field = MockTextField()
        weak var weakSut: GiniKeyboardAccessoryInstaller.Coordinator?

        do {
            let sut = makeCoordinator(currentFirstResponder: { field })
            weakSut = sut
            sut.apply(isActive: true, doneTintColor: .systemRed, onDone: {})
            // sut goes out of scope; nothing else retains the coordinator.
        }

        try? await Task.sleep(for: .milliseconds(20))

        #expect(weakSut == nil, "coordinator must deallocate — closure must not retain it")
        #expect(field.inputAccessoryView == nil, "async install must not fire on a deallocated coordinator")
    }

    // MARK: - Responder-chain helpers

    @Test("findFirstResponder returns the view when it is the first responder itself")
    func findFirstResponderReturnsSelfMatch() {
        let field = MockTextField()
        field.mockIsFirstResponder = true

        let result = GiniKeyboardAccessoryInstaller.Coordinator.findFirstResponder(in: field)

        #expect(result === field)
    }

    @Test("findFirstResponder recurses into subviews to locate the responder")
    func findFirstResponderRecurses() {
        let root = UIView()
        let mid = UIView()
        let field = MockTextField()
        field.mockIsFirstResponder = true
        mid.addSubview(field)
        root.addSubview(mid)

        let result = GiniKeyboardAccessoryInstaller.Coordinator.findFirstResponder(in: root)

        #expect(result === field)
    }

    @Test("findFirstResponder returns nil when nothing in the hierarchy is first responder")
    func findFirstResponderReturnsNil() {
        let root = UIView()
        root.addSubview(UIView())
        root.addSubview(MockTextField())  // mockIsFirstResponder defaults to false

        let result = GiniKeyboardAccessoryInstaller.Coordinator.findFirstResponder(in: root)

        #expect(result == nil)
    }

    @Test("currentFirstResponderUITextField returns nil when no key window has a first-responder text field")
    func currentFirstResponderReturnsNilInTestEnv() {
        // In the unit-test environment no key window hosts a first-responder UITextField;
        // exercise the scene-walk to prove it doesn't crash and returns nil.
        let result = GiniKeyboardAccessoryInstaller.Coordinator.currentFirstResponderUITextField()
        #expect(result == nil)
    }

    @Test("default init uses the scene-walk resolver — installIfNeeded is a safe no-op in tests")
    func defaultInitUsesSceneWalk() {
        // No `currentFirstResponder` override — exercises the default closure that calls
        // `Coordinator.currentFirstResponderUITextField()`. Must be a no-op in tests.
        let sut = GiniKeyboardAccessoryInstaller.Coordinator(doneTintColor: .systemBlue, onDone: {})
        sut.installIfNeeded()
        sut.uninstallIfInstalled()
    }
}

// MARK: - Test helpers

@MainActor
private func makeCoordinator(
    tintColor: UIColor = .systemBlue,
    onDone: @escaping () -> Void = {},
    currentFirstResponder: @escaping () -> UITextField? = { nil }
) -> GiniKeyboardAccessoryInstaller.Coordinator {
    GiniKeyboardAccessoryInstaller.Coordinator(doneTintColor: tintColor,
                                           onDone: onDone,
                                           currentFirstResponder: currentFirstResponder)
}

/**
 `UITextField` subclass that lets tests fake first-responder state and count
 `reloadInputViews` invocations without needing a real key window.
 */
private final class MockTextField: UITextField {
    var mockIsFirstResponder = false
    var reloadInputViewsCount = 0

    override var isFirstResponder: Bool { mockIsFirstResponder }

    override func reloadInputViews() {
        reloadInputViewsCount += 1
        super.reloadInputViews()
    }
}
