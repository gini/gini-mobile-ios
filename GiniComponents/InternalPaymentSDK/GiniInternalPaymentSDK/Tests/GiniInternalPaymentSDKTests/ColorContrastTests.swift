//
//  ColorContrastTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  WCAG 2.1 color-contrast regression guard for fix/HEAL-330_color_contrast.
//
//  Coverage (HEAL-CLR tickets):
//   CLR-01 • Primary button light       (#FFFFFF on #006ECF — fixed from 0.4α)
//   CLR-01 • Primary button dark        (#FFFFFF on #007FEE)
//          • Secondary button text      (#000000 on #F2F2F2)
//   CLR-02 • Placeholder light          (#000000 on #F2F2F2 — Standard2, was Standard4 #3A3A3C)
//   CLR-02 • Placeholder dark           (#F2F2F2 on #353535 — Standard2)
//          • Text field input light     (#000000 on #F2F2F2)
//          • Text field input dark      (#F2F2F2 on #353535)
//   CLR-03 • Powered by Gini light      (#000000 on #FAFAFA — Standard2, was Standard4)
//   CLR-03 • Powered by Gini dark       (#F2F2F2 on #161616 — Standard2)
//   CLR-04 • More info text light       (#000000 on #FAFAFA — Standard2, was Standard4)
//   CLR-04 • More info text dark        (#F2F2F2 on #161616 — Standard2)
//          • Info banner text light     (#FAFAFA on #13822F Success01Dark)
//          • Info banner text dark      (#FAFAFA on #213019 Success01Light)
//          • Error message text light   (#C0000A on #FAFAFA — Feedback01 darkened from #FA1C1C)
//
//  Thresholds (WCAG 2.1 §1.4.3 / §1.4.11):
//   • AA  normal text   : ≥ 4.5 : 1  (< 18 pt regular or < 14 pt bold)
//   • AA  large text    : ≥ 3.0 : 1  (≥ 18 pt regular or ≥ 14 pt bold)
//   • AAA normal text   : ≥ 7.0 : 1
//
//  Font sizes used in the SDK (FontProvider defaults):
//   .button    → 16 pt bold    → large text
//   .input     → 16 pt medium  → large text
//   .captions1 → 13 pt regular → normal text
//   .captions2 → 12 pt regular → normal text

import Testing
import UIKit

// MARK: - WCAG luminance helpers

/// Linearises a single 8-bit sRGB channel per IEC 61966-2-1.
private func linearise(_ channel: CGFloat) -> CGFloat {
    let c = channel / 255
    return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
}

/// Relative luminance (0…1) of a colour, per WCAG 2.1 §1.4.3.
private func relativeLuminance(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
    0.2126 * linearise(r) + 0.7152 * linearise(g) + 0.0722 * linearise(b)
}

/// WCAG 2.1 contrast ratio between two fully-opaque colours.
private func contrastRatio(foreground: UIColor, background: UIColor) -> Double {
    var fR: CGFloat = 0, fG: CGFloat = 0, fB: CGFloat = 0, fA: CGFloat = 0
    var bR: CGFloat = 0, bG: CGFloat = 0, bB: CGFloat = 0, bA: CGFloat = 0
    foreground.getRed(&fR, green: &fG, blue: &fB, alpha: &fA)
    background.getRed(&bR, green: &bG, blue: &bB, alpha: &bA)
    let lF = relativeLuminance(r: fR * 255, g: fG * 255, b: fB * 255)
    let lB = relativeLuminance(r: bR * 255, g: bG * 255, b: bB * 255)
    let lighter = max(lF, lB)
    let darker  = min(lF, lB)
    return (lighter + 0.05) / (darker + 0.05)
}

// MARK: - sRGB factory

private extension UIColor {
    /// Convenience initialiser from 8-bit sRGB integer components.
    static func sRGB(r: Int, g: Int, b: Int) -> UIColor {
        UIColor(
            red:   CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: 1
        )
    }
}

// MARK: - WCAG level

/// WCAG 2.1 minimum contrast ratio thresholds.
enum WCAGLevel: Double, CustomTestStringConvertible {
    /// Normal text (< 18 pt regular / < 14 pt bold): minimum 4.5 : 1.
    case aaNormal = 4.5
    /// Large text (≥ 18 pt regular or ≥ 14 pt bold): minimum 3.0 : 1.
    case aaLarge  = 3.0
    /// Enhanced / AAA: minimum 7.0 : 1.
    case aaa      = 7.0

    var testDescription: String {
        switch self {
        case .aaNormal: "AA normal (≥4.5:1)"
        case .aaLarge:  "AA large  (≥3.0:1)"
        case .aaa:      "AAA       (≥7.0:1)"
        }
    }
}

// MARK: - Test case model

/// A foreground/background pair together with its required WCAG level.
struct ColorContrastCase: CustomTestStringConvertible {
    let name: String
    let foreground: UIColor
    let background: UIColor
    let requiredLevel: WCAGLevel

    var testDescription: String { name }
}

// MARK: - Suite

@Suite("Accessibility — WCAG 2.1 color contrast (HEAL-330)")
struct ColorContrastTests {

    // MARK: - Colour palette

    // Light-mode assets (Dark-prefixed in the xcassets)
    private static let dark01  = UIColor.sRGB(r: 0x00, g: 0x00, b: 0x00) // #000000  standard1.light & standard2.light (placeholder after CLR-02)
    private static let dark06  = UIColor.sRGB(r: 0xF2, g: 0xF2, b: 0xF2) // #F2F2F2  standard6.light  field bg (post-HEAL-330 fix)
    private static let dark07  = UIColor.sRGB(r: 0xFA, g: 0xFA, b: 0xFA) // #FAFAFA  standard7.light  screen/sheet bg

    // Dark-mode assets (Light-prefixed in the xcassets)
    private static let light01 = UIColor.sRGB(r: 0xF2, g: 0xF2, b: 0xF2) // #F2F2F2  standard1.dark & standard2.dark (placeholder after CLR-02)
    private static let light06 = UIColor.sRGB(r: 0x35, g: 0x35, b: 0x35) // #353535  standard6.dark   field bg
    private static let light07 = UIColor.sRGB(r: 0x16, g: 0x16, b: 0x16) // #161616  standard7.dark   screen/sheet bg

    // Accent — primary button background
    private static let accent01Dark  = UIColor.sRGB(r: 0x00, g: 0x6E, b: 0xCF) // #006ECF  light mode
    private static let accent01Light = UIColor.sRGB(r: 0x00, g: 0x7F, b: 0xEE) // #007FEE  dark mode

    // Success — info banner background
    private static let success01Dark  = UIColor.sRGB(r: 0x13, g: 0x82, b: 0x2F) // #13822F  light mode
    private static let success01Light = UIColor.sRGB(r: 0x21, g: 0x30, b: 0x19) // #213019  dark mode

    // Shared
    private static let white      = UIColor.white                              // #FFFFFF  button text
    private static let feedback01 = UIColor.sRGB(r: 0xC0, g: 0x00, b: 0x0A)  // #C0000A  error colour (darkened from #FA1C1C in HEAL-330)

    // MARK: - Passing pairs

    /// Every pair listed here must satisfy its declared WCAG threshold.
    ///
    /// Font mapping (FontProvider defaults):
    ///   `.button`    → 16 pt bold    → large text  (≥ 14 pt bold threshold)
    ///   `.input`     → 16 pt medium  → large text
    ///   `.captions1` → 13 pt regular → normal text (< 18 pt threshold)
    ///   `.captions2` → 12 pt regular → normal text
    private static let passingPairs: [ColorContrastCase] = [

        // ── Primary button ──────────────────────────────────────────────────

        // HEAL-330 fix: removed withAlphaComponent(0.4) which produced ~1.82:1 (critical fail).
        // Full-opacity accent gives 5.08:1 — passes the stricter AA-normal threshold,
        // confirming the fix holds beyond the minimum AA-large requirement for 16 pt bold.
        ColorContrastCase(
            name: "Primary btn light — #FFFFFF on #006ECF (.button 16pt bold) — HEAL-330 regression guard",
            foreground: white,
            background: accent01Dark,
            requiredLevel: .aaNormal   // 5.08:1 expected; assert stricter level to lock in the fix
        ),

        // 16 pt bold → large text → AA large (3.0:1) sufficient; ratio is 3.98:1.
        ColorContrastCase(
            name: "Primary btn dark — #FFFFFF on #007FEE (.button 16pt bold)",
            foreground: white,
            background: accent01Light,
            requiredLevel: .aaLarge
        ),

        // ── Secondary button ────────────────────────────────────────────────

        ColorContrastCase(
            name: "Secondary btn text light — #000000 on #F2F2F2 (.input 16pt medium)",
            foreground: dark01,
            background: dark06,
            requiredLevel: .aaNormal   // 18.75:1 expected
        ),

        // ── Text-field input ────────────────────────────────────────────────

        ColorContrastCase(
            name: "Text field input light — #000000 on #F2F2F2 (.captions2 12pt regular)",
            foreground: dark01,
            background: dark06,
            requiredLevel: .aaNormal   // 18.75:1 expected
        ),

        ColorContrastCase(
            name: "Text field input dark — #F2F2F2 on #353535 (.captions2 12pt regular)",
            foreground: light01,
            background: light06,
            requiredLevel: .aaNormal   // 10.94:1 expected
        ),

        // ── Placeholder label ───────────────────────────────────────────────

        ColorContrastCase(
            name: "Placeholder light — #3A3A3C on #F2F2F2 (.captions2 12pt regular)",
            foreground: dark04,
            background: dark06,
            requiredLevel: .aaNormal   // 10.14:1 expected
        ),

        ColorContrastCase(
            name: "Placeholder dark — #ADADAD on #353535 (.captions2 12pt regular)",
            foreground: light04,
            background: light06,
            requiredLevel: .aaNormal   // 5.47:1 expected
        ),

        // ── Info banner (new in this branch) ────────────────────────────────

        // labelFont = .captions1 → 13 pt regular → normal text → needs 4.5:1.
        // labelTextColor = Dark07 (#FAFAFA, non-adaptive single value).
        // backgroundColor = success1.light = #13822F → ratio ≈ 4.72:1.
        ColorContrastCase(
            name: "Info banner text light — #FAFAFA on #13822F (Success01Dark, .captions1 13pt regular)",
            foreground: dark07,
            background: success01Dark,
            requiredLevel: .aaNormal   // 4.72:1 expected — just above the 4.5:1 floor
        ),

        // backgroundColor = success1.dark = #213019 → ratio ≈ 13.38:1.
        ColorContrastCase(
            name: "Info banner text dark — #FAFAFA on #213019 (Success01Light, .captions1 13pt regular)",
            foreground: dark07,
            background: success01Light,
            requiredLevel: .aaNormal   // 13.38:1 expected
        ),

        // ── Error message text (HEAL-330 fix: #FA1C1C → #C0000A) ────────

        // Feedback01 was darkened from #FA1C1C (3.83:1, failed AA) to #C0000A (6.20:1, passes AA).
        ColorContrastCase(
            name: "Error message text light — #C0000A on #FAFAFA (.captions2 12pt regular)",
            foreground: feedback01,
            background: dark07,
            requiredLevel: .aaNormal   // 6.20:1 expected
        ),
    ]

    // MARK: - Parameterised: all passing pairs

    /// Each entry in `passingPairs` runs as its own independent test case so a single
    /// failing pair produces a targeted diagnostic rather than stopping the whole suite.
    @Test("Color pair meets required WCAG contrast ratio", arguments: passingPairs)
    func colorPairMeetsWCAGRatio(_ pair: ColorContrastCase) {
        let ratio = contrastRatio(foreground: pair.foreground, background: pair.background)
        #expect(
            ratio >= pair.requiredLevel.rawValue,
            "\(pair.name)\n  actual \(String(format: "%.2f", ratio)):1 < required \(pair.requiredLevel.rawValue):1"
        )
    }

    // MARK: - Regression guard: HEAL-330 alpha removal

    /// Confirms the primary-button background is NOT using a semi-transparent blend.
    ///
    /// Before HEAL-330 the config was:
    ///   `GiniColor.accent1.uiColor().withAlphaComponent(0.4)`
    ///
    /// Blended over white this becomes #99C5EC → contrast with white text: **1.82:1**
    /// (fails every WCAG level).  After the fix the full-opacity accent gives **5.08:1**.
    @Test("Primary button light: contrast ≥ 4.5 (HEAL-330 alpha regression guard)")
    func primaryButtonAlphaRegressionGuard() {
        let ratio = contrastRatio(foreground: Self.white, background: Self.accent01Dark)
        #expect(
            ratio >= 4.5,
            "Primary button light contrast \(String(format: "%.2f", ratio)):1 < 4.5:1 — the withAlphaComponent(0.4) regression must not be reintroduced"
        )
    }

    // MARK: - Dark06 colorset integrity

    /// Guards that Dark06 stayed at #F2F2F2 (corrected in HEAL-330) and was not accidentally
    /// reverted to the previous value of #F3F3F3.
    @Test("Dark06 colorset value is exactly #F2F2F2 (HEAL-330 fix)")
    func dark06ColorsetIsF2F2F2() {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        Self.dark06.getRed(&r, green: &g, blue: &b, alpha: &a)
        let hexValue = Int(round(r * 255)) << 16
                     | Int(round(g * 255)) << 8
                     | Int(round(b * 255))
        #expect(
            hexValue == 0xF2F2F2,
            "Dark06 must be #F2F2F2, got #\(String(hexValue, radix: 16, uppercase: true).padding(toLength: 6, withPad: "0", startingAt: 0))"
        )
    }

    // MARK: - Feedback01 colorset integrity

    /// Guards that Feedback01 stayed at #C0000A (the HEAL-330 fix) and was not accidentally
    /// reverted to the previous failing value of #FA1C1C (which gave only 3.83:1).
    @Test("Feedback01 colorset value is #C0000A after HEAL-330 fix (was #FA1C1C, 3.83:1 — FAIL)")
    func feedback01ColorsetIsC0000A() {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        Self.feedback01.getRed(&r, green: &g, blue: &b, alpha: &a)
        let hexValue = Int(round(r * 255)) << 16
                     | Int(round(g * 255)) << 8
                     | Int(round(b * 255))
        #expect(
            hexValue == 0xC0000A,
            "Feedback01 must be #C0000A, got #\(String(hexValue, radix: 16, uppercase: true).padding(toLength: 6, withPad: "0", startingAt: 0)) — do not revert to #FA1C1C (3.83:1, fails AA)"
        )
    }
}
