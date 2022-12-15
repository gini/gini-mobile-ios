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

##### 1. Navigation bar
<center><img src="img/Customization guide/Navigation bar.jpg" height="70"/></center>
- Tint color &#8594;  `GiniConfiguration.navigationBarTintColor`
- Item tint color &#8594;  `GiniConfiguration.navigationBarItemTintColor`
- Title color &#8594;  `GiniConfiguration.navigationBarTitleColor`
- Item font &#8594;  `GiniConfiguration.navigationBarItemFont`
- Title font &#8594;  `GiniConfiguration.navigationBarTitleFont`

##### 2. Notice
<center><img src="img/Customization guide/Notice.jpg" height="70"/></center>
- Information background color &#8594;  `GiniConfiguration.noticeInformationBackgroundColor`
- Information text color &#8594;  `GiniConfiguration.noticeInformationTextColor`
- Error background &#8594;  `GiniConfiguration.noticeErrorBackgroundColor`
- Error text color `GiniConfiguration.noticeErrorTextColor`

##### 3. Tooltip
<center><img src="img/Customization guide/Tooltip.jpg" height="120"/></center>
- Background color &#8594;  `GiniConfiguration.fileImportToolTipBackgroundColor`
- Text color &#8594;  `GiniConfiguration.fileImportToolTipTextColor`
- Close button color &#8594;  `GiniConfiguration.fileImportToolTipCloseButtonColor`
- Text &#8594; 
    - <span style="color:#009EDF">*ginicapture.camera.fileImportTip*</span> localized string for file import tooltip
    - <span style="color:#009EDF">*ginicapture.camera.qrCodeTip*</span> localized string for qr code tooltip
    - <span style="color:#009EDF">*ginicapture.multipagereview.reorderContainerTooltipMessage*</span> localized string for reorder tooltip

##### 4. Gini Capture font

- Font &#8594;  `GiniConfiguration.customFont`

## Camera screen

<br>
<center><img src="img/Customization guide/Camera.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.camera.title*</span> localized string
- Close button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationCameraClose*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.camera.close*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarCameraTitleCloseButton`
- Help button
 - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationCameraHelp*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.camera.help*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarCameraTitleHelpButton`
      
##### 2. Camera preview
- Preview frame color &#8594;  `GiniConfiguration.cameraPreviewFrameColor`
- Guides color &#8594;  `GiniConfiguration.cameraPreviewCornerGuidesColor`
- Focus large image &#8594; <span style="color:#009EDF">*cameraFocusLarge*</span> image asset
- Focus large small &#8594; <span style="color:#009EDF">*cameraFocusSmall*</span> image asset
- Opaque view style (when tool tip is shown)  &#8594;  `GiniConfiguration.toolTipOpaqueBackgroundStyle`

##### 3. Camera buttons container
- Background color &#8594;  `GiniConfiguration.cameraButtonsViewBackgroundColor`
- Container view background color under the home indicator  &#8594;  `GiniConfiguration.cameraContainerViewBackgroundColor` 
- Capture button
  - Image &#8594; <span style="color:#009EDF">*cameraCaptureButton*</span> image asset
- Import button
	- Image &#8594; <span style="color:#009EDF">*documentImportButton*</span> image asset
- Captured images stack indicator color &#8594; `GiniConfiguration.imagesStackIndicatorLabelTextcolor`
- Flash toggle can be enabled through &#8594; `GiniConfiguration.flashToggleEnabled`
- Flash button
    - Image &#8594; <span style="color:#009EDF">*flashOn*</span> image asset
    - Image &#8594; <span style="color:#009EDF">*flashOff*</span> image asset

##### 4. QR code popup
<br>
<center><img src="img/Customization guide/QR code popup.jpg" height="70"/></center>
</br>
- Background color &#8594;  `GiniConfiguration.qrCodePopupBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Button color &#8594;  `GiniConfiguration.qrCodePopupButtonColor`
- Text color &#8594;  `GiniConfiguration.qrCodePopupTextColor` using `GiniColor` with dark mode and light mode colors
- Title &#8594; <span style="color:#009EDF">*ginicapture.camera.qrCodeDetectedPopup.buttonTitle*</span> localized string
- Message &#8594; <span style="color:#009EDF">*ginicapture.camera.qrCodeDetectedPopup.message*</span> localized string

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
	- Text color &#8594; `GiniConfiguration.reviewTextBottomColor`

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

## Help screen

<br>
<center><img src="img/Customization guide/Help screen.png" height="500"/></center>
</br>

##### 1. Navigation bar

- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationHelpBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.help.backToCamera*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpMenuTitleBackToCameraButton`

##### 2. Table View Cells

- Background color &#8594; `GiniConfiguration.helpScreenCellsBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 3. Background

- Background color &#8594; `GiniConfiguration.helpScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 4. Additional help menu items

- Custom help menu items &#8594; `GiniConfiguration.customMenuItems` an array of `HelpMenuViewController.Item` objects

