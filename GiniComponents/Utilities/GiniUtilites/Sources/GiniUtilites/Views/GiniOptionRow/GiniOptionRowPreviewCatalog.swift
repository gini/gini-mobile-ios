//
//  GiniOptionRowPreviewCatalog.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

#if DEBUG
import SwiftUI

/**
 Development-only catalog view used by `#Preview` blocks in
 `GiniOptionRow.swift` to render all eight configured states
 (two label variants × four states) against a neutral system-color scheme.

 Kept in a separate `#if DEBUG` file so the verbose preview `GiniColorScheme`
 builder does not bloat the production view file.
 */
@available(iOS 16.0, *)
struct GiniOptionRowPreviewCatalog: View {

    private static let printedTitle = "Printed on the document"
    private static let qrTitle = "In the QR code"
    private static let printedIBAN = "DE89 3704 0044 0532 0130 00"
    private static let qrIBAN = "PL12 1000 0111 0100 1000"
    private static let footer = "From Poland, not the sender's country"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader("Raw PDF assets (diagnostic — proves catalog load)")
                HStack(spacing: 16) {
                    rawAsset(name: "radio_unselected", caption: "unselected")
                    rawAsset(name: "radio_selected", caption: "selected")
                    rawAsset(name: "radio_disabled", caption: "disabled")
                    rawAsset(name: "radio_error", caption: "error")
                }

                sectionHeader("Unselected")
                radioRow(title: Self.printedTitle, content: Self.printedIBAN, state: .unselected)
                radioRow(title: Self.qrTitle, content: Self.qrIBAN, state: .unselected)

                sectionHeader("Selected")
                radioRow(title: Self.printedTitle, content: Self.printedIBAN, state: .selected)
                radioRow(title: Self.qrTitle, content: Self.qrIBAN, footer: Self.footer, state: .selected)

                sectionHeader("Error")
                radioRow(title: Self.printedTitle, content: Self.printedIBAN, state: .error)
                radioRow(title: Self.qrTitle, content: Self.qrIBAN, footer: Self.footer, state: .error)

                sectionHeader("Disabled")
                radioRow(title: Self.printedTitle, content: Self.printedIBAN, state: .disabled)
                radioRow(title: Self.qrTitle, content: Self.qrIBAN, footer: Self.footer, state: .disabled)

                sectionHeader("Informational (no radio, no background — parent owns the separator)")
                informationalRow(title: Self.printedTitle, content: Self.printedIBAN)
                informationalRow(title: Self.qrTitle, content: Self.qrIBAN, footer: Self.footer)

                sectionHeader("Informational (no radio, with background)")
                informationalRow(title: Self.printedTitle, content: Self.printedIBAN, background: Self.informationalBackground)
                informationalRow(title: Self.qrTitle, content: Self.qrIBAN, footer: Self.footer, background: Self.informationalBackground)
            }
        }
    }

    private func radioRow(title: String,
                          content: String,
                          footer: String? = nil,
                          state: GiniOptionRow.RadioButtonState) -> some View {
        GiniOptionRow(title: title,
                      content: content,
                      footer: footer,
                      variant: .radio(state),
                      giniColorScheme: Self.previewScheme,
                      onTap: { /* Preview-only: non-nil closure makes the row render as a Button so the pressed state is visible in previews; no action to perform. */ })
    }

    private func informationalRow(title: String,
                                  content: String,
                                  footer: String? = nil,
                                  background: GiniColor? = nil) -> some View {
        GiniOptionRow(title: title,
                      content: content,
                      footer: footer,
                      variant: .informational,
                      giniColorScheme: Self.previewScheme,
                      background: background)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    /// Displays the raw PDF asset side-by-side with its name so you can confirm the
    /// `GiniIcons.xcassets` catalog is being picked up in preview. When a state's
    /// imageset has no PDF yet (e.g. `radio_disabled`), the SwiftUI slot stays empty.
    @ViewBuilder
    private func rawAsset(name: String, caption: String, tint: Color? = nil) -> some View {
        VStack(spacing: 4) {
            if let uiImage = preferredImage(named: name) {
                let image = Image(uiImage: uiImage).resizable().frame(width: 24, height: 24)
                if let tint {
                    image.foregroundStyle(tint)
                } else {
                    image
                }
            } else {
                Image(systemName: "questionmark.square.dashed")
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            Text(caption).font(.caption2).foregroundStyle(.secondary)
        }
    }

    /// A `GiniColorScheme` built from iOS system colors so the preview reflects
    /// standard semantic hues without depending on an SDK-specific factory.
    static let previewScheme: GiniColorScheme = {
        let labelPair = pair(.label)
        let secondary = pair(.secondaryLabel)
        let tertiary = pair(.tertiaryLabel)
        let accent = pair(.systemBlue)
        let error = pair(.systemRed)
        let warningBG = pair(UIColor.systemPink.withAlphaComponent(0.1))

        return GiniColorScheme(
            background: .init(primary: pair(.systemBackground),
                              secondary: pair(.secondarySystemBackground)),
            actionSheet: .init(buttonBackground: pair(.systemGray5),
                               cancelButtonBackground: pair(.systemGray4)),
            alert: .init(background: pair(.systemBackground),
                         divider: pair(.separator)),
            navigationBar: .init(background: pair(.systemBackground),
                                 action: accent,
                                 navigation: labelPair),
            content: .init(navigation: labelPair, text: labelPair),
            bottomBar: .init(background: pair(.systemBackground),
                             border: pair(.separator)),
            container: .init(background: pair(.systemBackground)),
            placeholder: .init(background: pair(.systemGray6),
                               tint: pair(.systemGray)),
            text: .init(primary: labelPair,
                        secondary: secondary,
                        tertiary: tertiary,
                        accent: accent,
                        success: pair(.systemGreen),
                        error: error),
            icon: .init(primary: labelPair, secondary: secondary),
            pageController: .init(selected: accent, unselected: pair(.systemGray3)),
            error: .init(background: warningBG, icon: error),
            message: .init(backgroundSuccess: pair(UIColor.systemGreen.withAlphaComponent(0.1)),
                           contentSuccess: pair(.systemGreen),
                           backgroundWarning: warningBG,
                           contentWarning: pair(.systemOrange),
                           backgroundError: warningBG,
                           contentError: error),
            badge: .init(background: pair(.systemGray5), content: labelPair),
            button: .init(background: accent,
                          backgroundLoading: accent,
                          content: pair(.white)),
            buttonOutlined: .init(background: pair(.systemBackground), content: accent),
            textField: .init(background: pair(.systemGray6),
                             border: pair(.systemGray3),
                             focusedText: labelPair,
                             unfocusedText: secondary,
                             disabledText: tertiary,
                             errorText: error,
                             labelFocused: labelPair,
                             labelUnfocused: secondary,
                             labelDisabled: tertiary,
                             labelError: error,
                             supportingFocused: secondary,
                             supportingUnfocused: secondary,
                             supportingDisabled: tertiary,
                             supportingError: error,
                             trailingFocused: accent,
                             cursorEnabled: accent,
                             cursorError: error),
            toggle: .init(thumb: pair(.white),
                          trackOn: accent,
                          trackOff: pair(.systemGray3),
                          disabledTrack: pair(.systemGray5)),
            inputAccessoryView: .init(background: pair(.systemGray6),
                                      tintColor: accent,
                                      disabledTintColor: pair(.systemGray3))
        )
    }()

    private static func pair(_ color: UIColor) -> GiniColor {
        GiniColor(lightModeColor: color, darkModeColor: color)
    }

    static let informationalBackground = GiniColor(
        lightModeColor: UIColor.secondarySystemBackground,
        darkModeColor: UIColor.secondarySystemBackground
    )
}
#endif
