//
//  GiniExpandableInfoViewPreviewCatalog.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

#if DEBUG
import SwiftUI
import GiniUtilites

/** Preview host for `GiniExpandableInfoView` using real Bank SDK assets and scheme. */
@available(iOS 17.0, *)
struct GiniExpandableInfoViewPreviewCatalog: View {

    @State private var isExpanded: Bool

    init(initiallyExpanded: Bool) {
        self._isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        ScrollView {
            GiniExpandableInfoView(
                viewModel: .init(icon: GiniImages.shield.image ?? UIImage(),
                                 iconTint: Self.pair(.GiniBank.accent1),
                                 chevronIcon: GiniImages.chevronDownThin.image ?? UIImage(),
                                 title: "How do I protect myself?",
                                 backgroundColor: Self.fraudCardBackground,
                                 colorScheme: UIColor.giniBankColorScheme(),
                                 titleFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                 expandedAccessibilityValue: "Expanded",
                                 collapsedAccessibilityValue: "Collapsed"),
                isExpanded: $isExpanded
            ) {
                Text("Documents are sometimes changed to redirect payments. "
                     + "If you’re unsure which IBAN is right, ask the sender using "
                     + "contact details you already know.")
                    .font(Font(UIFont.systemFont(ofSize: 15, weight: .regular)))
                    .foregroundStyle(UIColor.giniBankColorScheme().text.secondary.swiftUIColor())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
    }

    /** Wraps a dynamic `UIColor` as a `GiniColor` (both arms share the same value). */
    private static func pair(_ color: UIColor) -> GiniColor {
        GiniColor(lightModeColor: color, darkModeColor: color)
    }

    /** Fraud-card surface: Gini accent at 20% in light, Bank `dark3` in dark. */
    private static let fraudCardBackground = GiniColor(lightModeColor: UIColor.GiniBank.accent1.withAlphaComponent(0.2),
                                                        darkModeColor: .GiniBank.dark3)
}

@available(iOS 17.0, *)
#Preview("Collapsed") {
    GiniExpandableInfoViewPreviewCatalog(initiallyExpanded: false)
}

@available(iOS 17.0, *)
#Preview("Expanded") {
    GiniExpandableInfoViewPreviewCatalog(initiallyExpanded: true)
}

@available(iOS 17.0, *)
#Preview("Collapsed · Dark") {
    GiniExpandableInfoViewPreviewCatalog(initiallyExpanded: false)
        .preferredColorScheme(.dark)
}

@available(iOS 17.0, *)
#Preview("Expanded · AX3 Dynamic Type") {
    GiniExpandableInfoViewPreviewCatalog(initiallyExpanded: true)
        .dynamicTypeSize(.accessibility3)
}
#endif
