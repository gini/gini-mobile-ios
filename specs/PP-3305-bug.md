# PP-3305: [iOS] Camera frame changes color from red to white during rotation

Status: fixed
Ticket: https://ginis.atlassian.net/browse/PP-3305

## Symptom

Observed: point camera at an invalid (non-payment) QR code — frame corners turn
red (`GiniCapture.error3`, set when the unsupported-QR alert appears, PP-3290).
Rotate the device: the corners revert to white.

Expected: the frame stays red across rotation while the invalid-QR state is
active. Reproduced by QA on iPhone and iPad, iOS 15–26.

## Reproduction

Cheapest faithful reproduction is a unit test (no simulator rotation needed —
the image rebuild happens on every `updatePreviewViewOrientation()` call,
regardless of whether the orientation actually changed):

1. Load `CameraPreviewViewController`'s view.
2. `changeCameraFrameColor(to: .red)` — frame image now tinted red.
3. Call `updatePreviewViewOrientation()` (what `viewWillTransition` invokes).
4. Inspect `cameraFrameView.image` pixels: no red remains — image was rebuilt
   from the pristine white asset.

## Root cause

`CameraPreviewViewController.updateFrameOrientation(with:)`
(`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Camera/CameraPreviewViewController.swift:259-280`),
called from `updatePreviewViewOrientation()` on every rotation
(`viewWillTransition`, line 251), rebuilds the frame image from the **original
untinted asset**:

```swift
if let image = cameraFocusImage?.cgImage {
    ...
    cameraFrameView.image = UIImage(cgImage: image, scale: 1.0, orientation: .left) // or .up
```

`cameraFocusImage` (line 52) is the pristine white "cameraFocus" asset. Any
tint previously applied by `changeCameraFrameColor(to:)` /
`changeQRFrameColor(to:)` (lines 371-378) is baked into a *copy* of the image
via `tintedImageWithColor`, so rebuilding from the raw asset discards it.
The controller keeps no record of the currently applied color, so nothing
restores it after the rebuild.

Mechanism cause → symptom: invalid QR sets frame to `error3` red
(`CameraViewController.showUnsupportedQRCodeAlert`, line 728) → user rotates →
`viewWillTransition` → `updatePreviewViewOrientation()` →
`updateFrameOrientation` re-assigns the white asset → red lost.

Note: `qrCodeFrameView` is *not* rebuilt on rotation, so QR-only mode keeps its
tint; only `cameraFrameView` (the document frame visible in the ticket's
photopayment flow) is affected.

## Proposed fix

Track the applied color and reapply it after the rebuild, all inside
`CameraPreviewViewController`:

- Add `private var currentFrameColor: UIColor?`.
- `changeCameraFrameColor(to:)` stores the color before tinting.
- `updateFrameOrientation(with:)` applies `tintedImageWithColor(currentFrameColor)`
  to the freshly built oriented image when a color is stored.

Minimal, no public API impact, fixes at the cause site (the rebuild), works
for every colored state (red error3, yellow warning3, green success2, white
light1).

## Regression test plan

Extend `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/CameraPreviewViewControllerTests.swift`
(XCTest — matches the file's existing framework):

- `testCameraFrameKeepsColorAfterOrientationUpdate`: load view, tint frame
  red, call `updatePreviewViewOrientation()`, assert the rebuilt
  `cameraFrameView.image` still contains red pixels (pixel-scan helper).
  Fails before the fix (image rebuilt white), passes after.

## Out of scope

- Refactoring the tint approach to template rendering + `tintColor` (broader
  change across frame views and `GiniBarButton`).
- Android twin PP-3219 (already Done).

## Open questions

None.
