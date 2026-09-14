# PP-1430: [iOS] HEIC file format issue

Status: fixed
Ticket: https://ginis.atlassian.net/browse/PP-1430

## Symptom

When a HEIC image is shared into the Bank SDK via **Open with** from the iOS **Files app**, `GiniCaptureDocumentBuilder.build(with openURL:completion:)` returns `nil`. The same file shared from the **Photos app** works.

The example app reports: *"Ihre Datei konnte nicht geöffnet werden. Bitte versuchen Sie es mit einer anderen Datei."* — the console shows the document builder returned nil.

Reported by Barclays/Veripark on the "Share with" flow. Currently unblocked for them (they enabled OpenWith another way), but the client-side rejection is still a real bug for anyone opening HEIC from Files.

## Reproduction

The bug reproduces cleanly at the unit-test layer — no simulator needed.

```swift
// CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/DataExtensionTests.swift
func testDataIsImage_returnsFalse_forHEICBytes() {
    // HEIC files are ISO Base Media containers whose first bytes are the
    // box-size (usually 0x00 0x00 0x00 0x20), followed by "ftyp" and a brand.
    let heicSignature: [UInt8] = [
        0x00, 0x00, 0x00, 0x20,          // box size
        0x66, 0x74, 0x79, 0x70,          // "ftyp"
        0x68, 0x65, 0x69, 0x63,          // "heic" brand
        0x00, 0x00, 0x00, 0x00           // padding
    ]
    let data = Data(heicSignature)

    // Fails before the fix (isImage returns false for HEIC); passes after.
    XCTAssertTrue(data.isImage, "isImage should recognise HEIC bytes")
}
```

For an end-to-end repro on device / simulator: run `GiniBankSDKExample`, share any `.heic` from the Files app via *Share → Open in Gini*. The `documentBuilder.build(with: url)` callback returns nil and the "not a valid document" alert appears.

## Root cause

`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Extensions/Data.swift`, `Data.mimeType` (lines 13–30) detects the file type from the **first byte** only:

```swift
private static let mimeTypeSignatures: [UInt8: String] = [
    0xFF: "image/jpeg",
    0x89: "image/png",
    0x47: "image/gif",
    0x49: "image/tiff",
    0x4D: "image/tiff",
    0x52: "image/webp",
    0x25: "application/pdf",
    0xD0: "application/vnd",
    0x46: "text/plain",
    0x3C: "application/xml"
]

var mimeType: String {
    var c: UInt8 = 0
    copyBytes(to: &c, count: 1)
    return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
}
```

HEIC files (ISO/IEC 23008-12, HEIF container) start with the box size — usually `0x00 0x00 0x00 0x20` — followed by the ASCII string `ftyp` and a brand identifier (`heic`, `heix`, `heif`, `mif1`, or `msf1`). **The first byte is `0x00`**, which is not in `mimeTypeSignatures`, so `mimeType` falls back to `"application/octet-stream"`.

`Data.isImage` (lines 50–55) then asks `UTTypeConformsTo(<UTI of octet-stream>, kUTTypeImage)` → **false**.

Trace through the failing path in `CaptureSDK/…/Core/Models/GiniCaptureDocument.swift`:

1. `GiniCaptureDocumentBuilder.build(with openURL:completion:)` (line 98) — opens the URL via a `UIDocument` subclass; `success = true` and `inputDocument.data` contains the raw HEIC bytes.
2. Delegates to `build(with data:fileName:)` (line 78).
3. `data.isPDF` → false, `data.isImage` → **false** (see above), `data.isXML` → false → returns `nil`.

The Photos-app path succeeds because the photo picker / `UIImage.jpegData` re-encodes the asset to JPEG before it reaches `build(with:)`; the first byte is then `0xFF`, `isImage` returns true, and a `GiniImageDocument` is created. The Files-app "Open with" path passes the raw HEIC bytes straight through.

The magic-byte table also misses BMP (`0x42 0x4D`), WEBP with `RIFF` header (which starts `0x52 0x49 0x46 0x46` — matches the WEBP entry only by first byte, not correctly), and every non-first-byte-distinguished image format. HEIC is the one this ticket is about.

## Proposed fix

**Minimal fix** — extend `Data.isImage` so it accepts HEIC files. Two viable shapes; picking one before implementing:

### Option A — HEIC-specific signature check (surgical)

Add a `Data.isHEIC` property that inspects bytes 4–11 for the `ftyp <brand>` marker and returns true for the five HEIF brands. `Data.isImage` returns true when either the existing UTI check passes or `isHEIC` is true.

Pros: minimal, targeted, no behaviour change for other formats.
Cons: still won't fix BMP or other unusual first-byte formats — but nothing in the ticket asks for those.

### Option B — ImageIO fallback (broader)

Keep the fast-path UTI check for the current formats; on failure, fall back to `CGImageSourceCreateWithData(data as CFData, nil)` and treat as image if the source contains at least one image.

Pros: fixes HEIC and every other image format ImageIO knows about.
Cons: larger behavioural surface — any binary blob ImageIO can decode now counts as image. Slightly slower.

**Recommendation: Option A.** Ticket is specifically about HEIC; the surgical fix carries the smaller regression surface. The magic-byte table's other gaps can be tracked separately if the team wants a broader clean-up.

### Files changed

- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Extensions/Data.swift` — add `isHEIC` and thread it into `isImage`. Add `jpegDataPreservingMetadata(compressionQuality:)` that transcodes via `CGImageSource → CGImageDestination` with a nil per-image properties dict, copying EXIF / TIFF / GPS from the source to the JPEG destination. Chosen over `UIImage(data:)?.jpegData(...)`, which decodes into a bitmap and drops every embedded property.
- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Models/GiniImageDocument.swift` — normalise HEIC input to JPEG at the top of `init(data:...)` via the new `Data.jpegDataPreservingMetadata()` helper. Every entry point that lands here (`GiniCaptureDocumentBuilder.build`, `GalleryCoordinator.addSelected`, direct picker calls) now guarantees the backend sees JPEG, and the metadata pipeline downstream (which expects JPEG or TIFF) sees the source's real EXIF/TIFF.
- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Document picker/Gallery/GalleryCoordinator.swift` — swap the pre-existing `!isImage` fallback from `UIImage(data:)?.jpegData(...)` to the same `Data.jpegDataPreservingMetadata()` helper. Gallery previously silently stripped EXIF whenever the fallback triggered; the fallback is narrow (bytes that fail `isImage` but `UIImage` can still decode), but consolidating around one helper keeps behaviour consistent across entry points and preserves metadata across the board.

No public API impact. `Data.isImage` is `internal`; `Data.isHEIC` and `Data.jpegDataPreservingMetadata()` are `internal` too. `GiniCaptureDocumentBuilder.build(...)` return type unchanged. Existing callers see the same shape; only more inputs succeed, and their EXIF/TIFF/GPS survives.

### Not changing (deliberate)

- `GiniImageDocument.acceptedImageTypes` — HEIC not added. Reason: those UTIs are used by `DocumentPickerCoordinator` to filter the file picker and by `NSItemProviderReading`. Adding HEIC to the picker changes UI behaviour and belongs in a separate scope decision (see Open questions).
- `ImageMetaInformationManager.imageByAddingMetadata` accepted-format guard — left as `(image.isJPEG || image.isTIFF)`. With the JPEG-normalising conversion at `GiniImageDocument.init` above, this guard never sees HEIC bytes at runtime, so no widening is needed.

## Regression test plan

**Location:** `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/DataHEICTests.swift` — new Swift Testing suite (`@Suite`, `@Test`, `#expect`, `#require`) per `mandatory-rules.md`.

Detection layer (fast, no real image encoder needed):

- `Data.isImage` returns true for all five HEIF brands (`heic`, `heix`, `heif`, `mif1`, `msf1`) — parametrised.
- `Data.isImage` still false for octet-stream noise; still true for JPEG magic (regression control).
- `GiniCaptureDocumentBuilder.build(with:fileName:)` returns a non-nil `GiniImageDocument` for HEIC-signature bytes.

Transcode layer (real HEIC via `CGImageDestination` with `public.heic` UTI):

- `GiniImageDocument.data.isJPEG` and `!.data.isHEIC` after initialising from real HEIC bytes.
- A known `TIFFSoftware` tag planted in the source's HEIC properties survives the transcode and is readable back off `GiniImageDocument.data`.

Extra direct-helper tests to add (currently missing):

- `Data.jpegDataPreservingMetadata()` returns nil for non-image bytes.
- `Data.jpegDataPreservingMetadata()` preserves a planted **EXIF** field (`kCGImagePropertyExifDateTimeOriginal` or `kCGImagePropertyExifLensModel`) across a HEIC → JPEG round-trip.
- `Data.jpegDataPreservingMetadata()` also works on JPEG input (idempotent — proves the helper isn't HEIC-only).

Optional (skip if flaky): a UI test in `GiniBankSDKExampleUITests` driving the Files-app share flow. HEIC fixtures on the simulator are non-trivial to seed, so I'd skip this and rely on the unit tests.

## Out of scope

- **Fixing other magic-byte gaps** — BMP, RIFF-based WEBP, non-first-byte formats. File a separate follow-up ticket if we want the full sweep.
- **Adding HEIC to the file picker's accepted types** (`GiniImageDocument.acceptedImageTypes` + `DocumentPickerCoordinator`). That's a product decision — surfaces HEIC in the *picker*, not just in "Open with". Do that under a fresh ticket if the team wants it.

## Open questions

- ~~Does the Gini backend accept HEIC bytes directly, or does the SDK's upload pipeline re-encode to JPEG before send?~~ **Resolved.** Backend does not accept HEIC. The fix now converts HEIC → JPEG at `GiniImageDocument.init` before the metadata pipeline runs, mirroring the existing `GalleryCoordinator.addSelected` pattern.
- Is `GiniImageDocument.isReviewable = true` for HEIC-originating documents safe? The review screen uses `UIImage(data:)`, which handles HEIC natively — should render fine, but worth an eyeball on device.
