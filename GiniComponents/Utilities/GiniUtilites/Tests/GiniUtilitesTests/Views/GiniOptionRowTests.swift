//
//  GiniOptionRowTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniUtilites

@Suite("GiniOptionRow — accessibility label composition")
struct GiniOptionRowAccessibilityLabelTests {

    @Test("Accessibility label joins title and content when no footer is provided")
    func accessibilityLabelOmitsFooterWhenNil() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "Printed on the document",
                                                         content: "DE89 3704 0044 0532 0130 00",
                                                         footer: nil)

        #expect(label == "Printed on the document, DE89 3704 0044 0532 0130 00",
                "No trailing separator or footer should leak when footer is nil.")
    }

    @Test("Accessibility label appends the footer when present so the warning is announced")
    func accessibilityLabelIncludesFooter() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "In the QR code",
                                                         content: "PL12 1000 0111 0100 1000",
                                                         footer: "From Poland, not the sender's country")

        #expect(label == "In the QR code, PL12 1000 0111 0100 1000, From Poland, not the sender's country",
                "Footer must be included verbatim so VoiceOver reads the warning in one pass.")
    }

    @Test("Accessibility label passes an empty footer string through — callers must pre-filter",
          arguments: [
            ("", "Title, Content, "),
            ("Warning", "Title, Content, Warning")
          ])
    func accessibilityLabelPassesThroughEmptyFooter(footer: String, expected: String) {
        let label = GiniOptionRowAccessibility.makeLabel(title: "Title",
                                                         content: "Content",
                                                         footer: footer)

        #expect(label == expected,
                "An empty footer string is not treated as absent — callers should pass nil to omit it.")
    }
}
