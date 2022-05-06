Customization guide
=============================

The Gini Capture SDK components can be customized either through the `GiniConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Camera screen](#camera-screen)
- [Review screen](#review-screen)
- [Multipage Review screen](#multipage-review-screen)
- [Analysis screen](#analysis-screen)
- [Supported formats screen](#supported-formats-screen)
- [Open with tutorial screen](#open-with-tutorial-screen)
- [Capturing tips screen](#capturing-tips-screen)
- [Gallery album screen](#gallery-album-screen)
- [Onboarding screens](#onboarding-screens)
- [Help screen](#help-screen)


## Supporting dark mode

Some background and text colors use the `GiniColor` type with which you can set colors for dark and light modes. Please make sure to set contrasting images to the background colors in your `.xcassets` for the Gini Capture SDK images you override (e.g. `onboardingPage1`). The text colors should also be set in contrast to the background colors.

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

## Multipage Review screen

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

## Supported formats screen

<br>
<center><img src="img/Customization guide/Supported formats.jpg" height="500"/></center>
</br>

##### Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*arrowBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.help.backToMenu*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Supported format cells
- Supported fortmats icon &#8594; <span style="color:#009EDF">*supportedFormatsIcon*</span> image asset
- Supported formats icon color &#8594; `GiniConfiguration.supportedFormatsIconColor`
- Non supported fortmats icon &#8594; <span style="color:#009EDF">*nonSupportedFormatsIcon*</span> image asset
- Non supported formats icon color &#8594; `GiniConfiguration.nonSupportedFormatsIconColor`

## Open with tutorial screen

<br>
<center><img src="img/Customization guide/Open with tutorial.jpg" height="500"/></center>
</br>

##### Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*arrowBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.help.backToMenu*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Header
- Text &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.collectionHeader*</span> localized string

##### 2. Open with steps
- App name &#8594; `GiniConfiguration.openWithAppNameForTexts`
- Step indicator color &#8594; `GiniConfiguration.stepIndicatorColor`
- Step 1
	- Title &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step1.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step1.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep1* (German) and *openWithTutorialStep1_en* (English)</span> image assets
- Step 2
	- Title &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step2.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step2.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep2* (German) and *openWithTutorialStep2_en* (English)</span> image assets
- Step 3
	- Title &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step3.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.step3.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep3* (German) and *openWithTutorialStep3_en* (English)</span> image assets

## Capturing tips screen

<br>
<center><img src="img/Customization guide/No results.jpg" height="500"/></center>
</br>

##### 1. Capturing tip images
- Tip 1 image &#8594; <span style="color:#009EDF">*captureSuggestion1*</span> image asset
- Tip 2 image &#8594; <span style="color:#009EDF">*captureSuggestion2*</span> image asset
- Tip 3 image &#8594; <span style="color:#009EDF">*captureSuggestion3*</span> image asset
- Tip 4 image &#8594; <span style="color:#009EDF">*captureSuggestion4*</span> image asset
- Tip 5 image &#8594; <span style="color:#009EDF">*captureSuggestion5*</span> image asset

##### 2. Go to camera button
- Background color &#8594; `GiniConfiguration.noResultsBottomButtonColor`
- Text color &#8594; `GiniConfiguration.noResultsBottomButtonTextColor`
- Corner radius &#8594; `GiniConfiguration.noResultsBottomButtonCornerRadius`

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

