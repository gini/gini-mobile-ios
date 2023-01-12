Customization guide
=============================

The Gini Capture SDK components can be customized either through the `GiniConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Onboarding screens](#onboarding-screens)
- [Camera screen](#camera-screen)
- [Gallery album screen](#gallery-album-screen)
- [Review screen](#review-screen)
- [Analysis screen](#analysis-screen)
- [Help screens](#help-screens)
- [No result screen](#no-result-screen)
- [Error screens](#error-screens)

## Colors

We are providing a global color palette `GiniColors.xcassets` which you are free to override. The custom colors will be then applied on all screens.
You can find the names of the colors in [GiniColors.xcassets](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/GiniColors.xcassets).

 You can view our color palette here:

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D14%253A355%26t%3DwpenBBM8QsagJzOg-1" allowfullscreen></iframe>

## Typography

We provide a global typography based on text appearance styles from `UIFont.TextStyle`. 

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D123%253A2326%26t%3DwpenBBM8QsagJzOg-1" allowfullscreen></iframe>

To override them in your application please use `GiniConfiguration.updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle)`. For example:

```swift

    // If you need to scale your font please use our method `scaledFont()`. Please, find the example below.
    let configuration = GiniBankConfiguration.shared
    let customFontToBeScaled = UIFont.scaledFont(UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 7, weight: .regular), textStyle: .caption1)
    configuration.updateFont(customFontToBeScaled, for: .caption1)

    // If you would like to pass us already scaled font.
    let customScaledFont = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 28))
    configuration.updateFont(customScaledFont, for: .caption2)
```

## Images

Images customization is done via overriding of [GiniImages.xcassets](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/GiniImages.xcassets) resources.

## Text

 Text customization is done via overriding of string resources.

 You can find all the string resources in [Localizable.strings](https://github.com/gini/gini-mobile-ios/blob/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/de.lproj/Localizable.strings).

## Generic components

##### 1. Top Navigation bar

Colors, typography, texts can be customized as described above.

To inject your own navigation bar view you need to pass your navigation view controller to 
`GiniConfiguration.shared.customNavigationController`.
The view from the custom navigation view controller will then be displayed on all screens as the top navigation bar.

##### 2. Bottom Navigation bar

You can opt to show a bottom navigation bar. To enable it pass `true` to
`GiniConfiguration.shared.bottomNavigationBarEnabled`.

**Note**:  The top navigation bar will still be used, but its  functionality will be limited to showing the screen's title and
an optional close button.
Please inject a custom top navigation bar if your design requires it even if you have enabled the bottom navigation bar.

For each screen we provide a possibility to inject a custom bottom navigation bar.
More details will be added below during the specific screen customization.

## Camera screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D243%253A3306%26t%3DboRmrY5QfLYhGfPT-1" allowfullscreen></iframe>

### Single Page

By default, the Gini Capture SDK is configured to capture single page documents.
No further configuration is required for this.

### Multi-Page

The multi-page feature allows the SDK to capture documents with multiple pages.

To enable this feature simply pass `true` to `GiniConfiguration.shared.multipageEnabled`.

### Camera

* Enable the flash toggle button:
   To allow users toggle the camera flash pass `true` to `GiniConfiguration.shared.flashToggleEnabled`.

* Turn off flash by default:
   Flash is on by default, and you can turn it off by passing `false` to `GiniConfiguration.shared.flashOnByDefault`.

 ### QR Code Scanning

When a supported QR code is detected with valid payment data, the QR Code will be processed automatically without any further user interaction.
The QR Code scanning may be triggered directly without the need to analyze the document.

If the QR code does not have a supported payment format then a popup informs the user that a QR code was detected, but it cannot be used.

Please find more information in the [QR Code scanning guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/qr-code-scanning-guide.html).

### QR Code Only

During QR Code only mode the capture and import controls will be hidden from the camera screen.

For enabling QR code only mode the both flags `GiniConfiguration.shared.qrCodeScanningEnabled` and `GiniConfiguration.shared.onlyQRCodeScanningEnabled` should be `true`.

More information about the customization is available [here](https://www.figma.com/file/H4WFJ4xaw4YNU4VaJYWiQq/iOS-Gini-Capture-SDK-2.0.0-UI-Customisation?node-id=243%3A3306&t=boRmrY5QfLYhGfPT-1)

### Document Import

This feature enables the Gini Capture SDK to import documents from the camera screen. When it's enabled an additional button is shown next to the camera trigger. Using this button allows the user to pick either an image or a pdf from the device.

Please find more information in the [Import PDFs and images guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/import-pdfs-and-images-guide.html).

## Review screen

<br>
<center><img src="img/Customization guide/Review.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.title*</span> localized string
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.back*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarReviewTitleBackButton`
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.continue*</span> localized string

##### 2. Review top view
- Title &#8594; <span style="color:#009EDF">*ginicapture.review.top*</span> localized string

##### 3. Review bottom view
- Background color &#8594; `GiniConfiguration.reviewBottomViewBackgroundColor`
- Rotation button image &#8594;  <span style="color:#009EDF">*reviewRotateButton*</span> image asset
- Rotation message
	- Text &#8594; <span style="color:#009EDF">*ginicapture.review.bottom*</span> localized string

## Review screen

<br>
<center><img src="img/Customization guide/MultipageReview.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.back*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarReviewTitleBackButton`
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.continue*</span> localized string

##### 2. Main collection
- Opaque view style (when tool tip is shown)  &#8594;  `GiniConfiguration.multipageToolTipOpaqueBackgroundStyle`

##### 3. Page item
- Page upload state icon
  - Successful upload &#8594; <span style="color:#009EDF">*successfullUploadIcon*</span> image asset
  - Failed upload &#8594; <span style="color:#009EDF">*failureUploadIcon*</span> image asset
- Page upload state icon background color
  - Successful upload &#8594; `GiniConfiguration.multipagePageSuccessfullUploadIconBackgroundColor`
  - Failed upload &#8594; `GiniConfiguration.multipagePageFailureUploadIconBackgroundColor`
- Page circle indicator color &#8594; `GiniConfiguration.indicatorCircleColor` using `GiniColor` with dark mode and light mode colors
- Page indicator color &#8594; `GiniConfiguration.multipagePageIndicatorColor` 
- Page background color &#8594; `GiniConfiguration.multipagePageBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Page selected indicator color &#8594; `GiniConfiguration.multipagePageSelectedIndicatorColor`
- Page draggable icon tint color &#8594; `GiniConfiguration.multipageDraggableIconColor`

##### 4. Bottom container
- Background color &#8594; `GiniConfiguration.multipagePagesContainerAndToolBarColor` using `GiniColor` with dark mode and light mode colors
- Rotation button image &#8594;  <span style="color:#009EDF">*rotateImageIcon*</span> image asset
- Delete button image &#8594;  <span style="color:#009EDF">*trashIcon*</span> image asset

## Analysis screen

<br>
<center><img src="img/Customization guide/Analysis.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Cancel button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationAnalysisBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.analysis.back*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarAnalysisTitleBackButton`

##### 2. PDF Information view
- Text color &#8594; `GiniConfiguration.analysisPDFInformationTextColor`
- Background color &#8594; `GiniConfiguration.analysisPDFInformationBackgroundColor`

##### 3. Loading view
- Indicator color &#8594; `GiniConfiguration.analysisLoadingIndicatorColor` (Only with PDFs)
- Text &#8594; <span style="color:#009EDF">*ginicapture.analysis.loadingText*</span> localized string

## Help screens

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D141%253A2328%26t%3DwpenBBM8QsagJzOg-1" allowfullscreen></iframe>

You can show your own help screens in the Gini Capture SDK.
You can pass the title and view controller for each screen to the
`GiniConfiguration.shared.customMenuItems` using a list of `HelpMenuItem` structs:

``` swift

        let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())

        configuration.customMenuItems = [customMenuItem]
 ```           
 
The example implementation is availible [here](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift).

You can also disable the supported formats help screen by passing `false` to
`GiniConfiguration.shared.shouldShowSupportedFormatsScreen`.


## Gallery album screen

<br>
<center><img src="img/Customization guide/Gallery album.jpg" height="500"/></center>
</br>

##### 1. Selected image
- Selected item check color &#8594; `GiniConfiguration.galleryPickerItemSelectedBackgroundCheckColor`
- Background color &#8594; `GiniConfiguration.galleryScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

## Onboarding screens

<br>
<center><img src="img/Customization guide/Onboarding.png" height="500"/></center>
</br>

##### 1. Background
- Background Color &#8594; `GiniConfiguration.onboardingScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 2. Image
- Page image &#8594; <span style="color:#009EDF">*onboardingPage**</span> image asset

##### 3. Text
- Color &#8594; `GiniConfiguration.onboardingTextColor` using `GiniColor` with dark mode and light mode colors

##### 4. Page indicator
- Color &#8594; `GiniConfiguration.onboardingPageIndicatorColor` using `GiniColor` with dark mode and light mode colors

##### 5. Current page indicator
- Color &#8594; `GiniConfiguration.onboardingCurrentPageIndicatorColor` using `GiniColor` with dark mode and light mode colors
- Alpha &#8594; `GiniConfiguration.onboardingCurrentPageIndicatorAlpha` sets alpha to the `GiniConfiguration.onboardingCurrentPageIndicatorColor`
