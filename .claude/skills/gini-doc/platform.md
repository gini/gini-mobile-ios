# gini-doc platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but Android content. If you
  add a section here that the shared workflow depends on, add the matching
  section to the Android platform.md too.
-->

## Platform argument

The only valid `--platform` value in this repository is `ios`.

## Source roots in scope

Keep only changed files under these directories — everything else is out of
scope:

- `BankSDK/GiniBankSDK/Sources/` (Bank SDK source root)
- `BankAPILibrary/GiniBankAPILibrary/Sources/` (Bank API library source root)
- `CaptureSDK/GiniCaptureSDK/Sources/` (Capture SDK source root, if the
  feature touches shared capture logic)

Skip test files, example apps, CI scripts, package manifests (`Package.swift`,
`Package-release.swift`), localization strings (collected separately via the
localization step), and build output.

## Localization strings

- `Resources/de.lproj/Localizable.strings` holds the **German defaults**
  (maps to the "Default (de)" column in the output tables).
- `Resources/en.lproj/Localizable.strings` holds the **English strings**
  (maps to the "Default (en)" column).

Keys are dot-notation following `<sdk>.<feature>.<screen>.<element>`, with a
module prefix: `ginibank.` in BankSDK and `ginicapture.` in CaptureSDK.
Derive feature key patterns from these conventions — e.g.
`cross-border-payments` → keys starting with `ginibank.`/`ginicapture.` that
contain `crossBorder`, `cx`, or the feature term — never from snake_case
guesses.

Search the relevant modules for keys matching the feature pattern:

```bash
grep -r "<feature-key-pattern>" --include="*.strings" BankSDK/GiniBankSDK/Sources/
grep -r "<feature-key-pattern>" --include="*.strings" CaptureSDK/GiniCaptureSDK/Sources/
```

## Configuration surface

Features are toggled via public properties on the `GiniBankConfiguration`
singleton (`GiniBankConfiguration.shared`), defined in
`BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankConfiguration.swift`,
and passed to the SDK entry point
`GiniBank.viewController(withClient:...)`.

## OS permissions → Info.plist requirements

Infer `Info.plist` requirements from OS APIs used in source:

- `PHPhotoLibrary` (add-only access) → `NSPhotoLibraryAddUsageDescription`
  required
- `PHPickerViewController` / full photo library access →
  `NSPhotoLibraryUsageDescription` required
- `AVCaptureDevice` / camera capture → `NSCameraUsageDescription` required

Without the matching usage-description key, iOS prevents the permission
dialog from appearing and the feature will not work.

## Symbols to skip

- Anything `internal`, `private`, or prefixed with `_`
- Internal wiring such as `GiniCaptureUserDefaultsStorage` and the internal
  `GiniConfiguration`

## Code sample conventions

- Code block language tags: `swift` for SDK usage, `xml` for `Info.plist`
  entries, `json` for extraction payload examples.
- Multi-parameter calls use the repository's one-parameter-per-line style:
  first parameter on the opening-paren line, subsequent parameters vertically
  aligned (see `CLAUDE.md` › Code Style).
- Extraction results are delivered via the `GiniCaptureResultsDelegate`
  protocol (see the `result-callback` snippet below) — there is no result
  enum on iOS; empty results and cancellation arrive as separate delegate
  callbacks.

## Terms

Values for the `[term: name]` references used in the shared templates.

| Term | Value |
|---|---|
| `config-object` | `GiniBankConfiguration` |
| `sdk-entry-point` | `GiniBank` |
| `manifest-file` | `Info.plist` |
| `result-type` | `GiniCaptureResultsDelegate` callback |
| `success-result-case` | `giniCaptureAnalysisDidFinishWith(result:)` |
| `empty-result-case` | `giniCaptureDidEnterManually()` (no-results path) |
| `cleanup-call` | `GiniBankConfiguration.shared.cleanup()` |
| `code-language` | Swift (code block tag `swift`) |
| `ui-customization-guide-url` | `https://gini.atlassian.net/wiki/spaces/IBSV/overview` <!-- TOBEADDED: replace with the exact iOS UI Customisation Guide page for the current SDK version --> |

## Snippets

Code blocks for the `[snippet: name]` references used in the shared
templates. Keep the `[placeholder]` markers — the skill fills them from
source when generating a page.

### `enable-configuration`

```swift
lazy var giniBankConfiguration: GiniBankConfiguration = {
    let configuration = GiniBankConfiguration.shared
    configuration.[propertyName] = [enableValue]
    // ...
    return configuration
}()

let viewController = GiniBank.viewController(withClient: client,
                                             importedDocuments: visionDocuments,
                                             configuration: giniBankConfiguration,
                                             resultsDelegate: self,
                                             documentMetadata: documentMetadata,
                                             api: apiEnvironment.api,
                                             userApi: apiEnvironment.userApi,
                                             trackingDelegate: trackingDelegate)
```

### `revert-configuration`

```swift
lazy var giniBankConfiguration: GiniBankConfiguration = {
    let configuration = GiniBankConfiguration.shared
    configuration.[propertyName] = [defaultValue] // default
    // ...
    return configuration
}()
```

### `flag-configuration`

```swift
lazy var giniBankConfiguration: GiniBankConfiguration = {
    let configuration = GiniBankConfiguration.shared
    configuration.[propertyName] = true
    configuration.[tuningPropertyName] = [value] // include tuning properties, e.g. thresholds
    // ...
    return configuration
}()
```

### `result-callback`

```swift
extension YourViewController: GiniCaptureResultsDelegate {

    /// Called when the analysis finished with results.
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
        handleExtractions(result.extractions)
    }

    /// Called when the analysis was cancelled.
    func giniCaptureDidCancelAnalysis() {
        handleCancellation()
    }

    /// Called when "Enter Manually" was tapped on the No Results or Error screen.
    func giniCaptureDidEnterManually() {
        handleEnterManually()
    }
}
```

### `os-integration-declaration`

```xml
[Info.plist entry — usage-description key, document type (CFBundleDocumentTypes),
or imported UTI declaration, copied from verified source]
```
