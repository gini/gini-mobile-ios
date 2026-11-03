//
//  BottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — presents `content` as a medium-detent bottom sheet.
//  iOS 16+: uses SwiftUI's native `.sheet` + `.presentationDetents`.
//  iOS 15:  bridges to UIKit's `UISheetPresentationController` via a
//           UIViewControllerRepresentable backed by UIHostingController.
//

import SwiftUI
import UIKit

extension View {
    @ViewBuilder
    func bottomSheet<Content: View>(isPresented: Binding<Bool>,
                                    @ViewBuilder content: @escaping () -> Content) -> some View {
        if #available(iOS 16.0, *) {
            self.sheet(isPresented: isPresented) {
                content()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        } else {
            self.background(
                MediumDetentSheetPresenter(isPresented: isPresented, content: content)
            )
        }
    }
}

private struct MediumDetentSheetPresenter<Content: View>: UIViewControllerRepresentable {

    @Binding var isPresented: Bool
    let content: () -> Content

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        if isPresented, host.presentedViewController == nil {
            let hostingVC = UIHostingController(rootView: content())
            if let sheet = hostingVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            hostingVC.presentationController?.delegate = context.coordinator
            DispatchQueue.main.async {
                host.present(hostingVC, animated: true)
            }
        } else if !isPresented, host.presentedViewController != nil {
            host.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var isPresented: Binding<Bool>

        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            isPresented.wrappedValue = false
        }
    }
}
