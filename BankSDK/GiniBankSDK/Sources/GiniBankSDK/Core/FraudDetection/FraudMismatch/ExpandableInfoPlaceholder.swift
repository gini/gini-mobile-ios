//
//  ExpandableInfoPlaceholder.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 Local stub for the upstream `GiniExpandableInfoView` SwiftUI primitive.
 Mirrors the expected call-site shape (title / message / icon /
 `@Binding<Bool>`) via `DisclosureGroup` so this feature can build before
 the real component merges. Delete this file and swap
 `ExpandableInfoPlaceholder(…)` for `GiniExpandableInfoView(…)` once it
 lands.
 */
struct ExpandableInfoPlaceholder: View {

    let title: String
    let message: String
    let icon: Image
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Constants.bodyTopPadding)
        } label: {
            HStack(spacing: Constants.labelSpacing) {
                icon
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .padding(Constants.innerPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.gray.opacity(Constants.backgroundOpacity))
        )
    }

    private enum Constants {
        static let bodyTopPadding: CGFloat = 8
        static let labelSpacing: CGFloat = 12
        static let innerPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let backgroundOpacity: CGFloat = 0.1
    }
}
