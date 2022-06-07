Customization guide
=============================

The Gini Bank SDK components can be customized either through the `GiniBankConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

If you plan to use a custom name for localizable strings, you need to set it in `GiniBankConfiguration.localizedStringsTableName`.

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
- [No results screen](#no-results-screen)
- [Albums screen](#albums-screen)
- [Return assistant](#return-assistant)
  - [Onboarding screen](#onboarding-screen)
  - [Info box](#info-box)
  - [Digital invoice screen](#digital-invoice-screen)
  - [Return reason action sheet](#return-reason-action-sheet)
  - [Info dialog](#info-dialog)
  - [Edit line item screen](#edit-line-item-screen)
  
## Supporting dark mode

Some background and text colors use the `GiniColor` type with which you can set colors for dark and light modes. Please make sure to set contrasting images to the background colors in your `.xcassets` for the Gini Bank SDK images you override (e.g. `onboardingPage1`). The text colors should also be set in contrast to the background colors.

## Generic components

##### 1. Navigation bar
<center><img src="img/Customization guide/Navigation bar.jpg" height="70"/></center>
- Tint color &#8594;  `GiniBankConfiguration.navigationBarTintColor`
- Item tint color &#8594;  `GiniBankConfiguration.navigationBarItemTintColor`
- Title color &#8594;  `GiniBankConfiguration.navigationBarTitleColor`
- Item font &#8594;  `GiniBankConfiguration.navigationBarItemFont`
- Title font &#8594;  `GiniBankConfiguration.navigationBarTitleFont`

##### 2. Notice
<center><img src="img/Customization guide/Notice.jpg" height="70"/></center>
- Information background color &#8594;  `GiniBankConfiguration.noticeInformationBackgroundColor`
- Information text color &#8594;  `GiniBankConfiguration.noticeInformationTextColor`
- Error background &#8594;  `GiniBankConfiguration.noticeErrorBackgroundColor`
- Error text color `GiniBankConfiguration.noticeErrorTextColor`

##### 3. Tooltip
<center><img src="img/Customization guide/Tooltip.jpg" height="120"/></center>
- Background color &#8594;  `GiniBankConfiguration.fileImportToolTipBackgroundColor`
- Text color &#8594;  `GiniBankConfiguration.fileImportToolTipTextColor`
- Close button color &#8594;  `GiniBankConfiguration.fileImportToolTipCloseButtonColor`
- Text &#8594; 
	- <span style="color:#009EDF">*ginicapture.camera.fileImportTip*</span> localized string for file import tooltip
	- <span style="color:#009EDF">*ginicapture.camera.qrCodeTip*</span> localized string for qr code tooltip
	- <span style="color:#009EDF">*ginicapture.multipagereview.reorderContainerTooltipMessage*</span> localized string for reorder tooltip

##### 4. GVL font

- Font &#8594;  `GiniBankConfiguration.customFont`

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
	  -  Title &#8594; `GiniBankConfiguration.navigationBarCameraTitleCloseButton`
- Help button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationCameraHelp*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.camera.help*</span> localized string
     - With title only
      -  Title &#8594; `GiniBankConfiguration.navigationBarCameraTitleHelpButton`   

##### 2. Camera preview
- Preview frame color &#8594;  `GiniBankConfiguration.cameraPreviewFrameColor`
- Guides color &#8594;  `GiniBankConfiguration.cameraPreviewCornerGuidesColor`
- Focus large image &#8594; <span style="color:#009EDF">*cameraFocusLarge*</span> image asset
- Focus large small &#8594; <span style="color:#009EDF">*cameraFocusSmall*</span> image asset
- Opaque view style (when tool tip is shown)  &#8594;  `GiniBankConfiguration.toolTipOpaqueBackgroundStyle`

##### 3. Camera buttons container
- Background color &#8594;  `GiniBankConfiguration.cameraButtonsViewBackgroundColor`
- Container view background color under the home indicator  &#8594;  `GiniBankConfiguration.cameraContainerViewBackgroundColor` 
- Capture button
  - Image &#8594; <span style="color:#009EDF">*cameraCaptureButton*</span> image asset
- Import button
	- Image &#8594; <span style="color:#009EDF">*documentImportButton*</span> image asset
- Captured images stack indicator color &#8594; `GiniBankConfiguration.imagesStackIndicatorLabelTextcolor`
- Flash toggle can be enabled through &#8594; `GiniBankConfiguration.flashToggleEnabled`
- Flash button
    - Image &#8594; <span style="color:#009EDF">*flashOn*</span> image asset
    - Image &#8594; <span style="color:#009EDF">*flashOff*</span> image asset

##### 4. QR code popup
<br>
<center><img src="img/Customization guide/QR code popup.jpg" height="70"/></center>
</br>
- Background color &#8594;  `GiniBankConfiguration.qrCodePopupBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Button color &#8594;  `GiniBankConfiguration.qrCodePopupButtonColor`
- Text color &#8594;  `GiniBankConfiguration.qrCodePopupTextColor` using `GiniColor` with dark mode and light mode colors
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
	  -  Title &#8594; `GiniBankConfiguration.navigationBarReviewTitleBackButton`
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.continue*</span> localized string

##### 2. Review top view
- Title &#8594; <span style="color:#009EDF">*ginicapture.review.top*</span> localized string

##### 3. Review bottom view
- Background color &#8594; `GiniBankConfiguration.reviewBottomViewBackgroundColor`
- Rotation button image &#8594;  <span style="color:#009EDF">*reviewRotateButton*</span> image asset
- Rotation message
	- Text &#8594; <span style="color:#009EDF">*ginicapture.review.bottom*</span> localized string
	- Text color &#8594; `GiniBankConfiguration.reviewTextBottomColor`

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
	  -  Title &#8594; `GiniBankConfiguration.navigationBarReviewTitleBackButton`
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginicapture.navigationbar.review.continue*</span> localized string

##### 2. Main collection
- Opaque view style (when tool tip is shown)  &#8594;  `GiniBankConfiguration.multipageToolTipOpaqueBackgroundStyle`

##### 3. Page item
- Page upload state icon
  - Successful upload &#8594; <span style="color:#009EDF">*successfullUploadIcon*</span> image asset
  - Failed upload &#8594; <span style="color:#009EDF">*failureUploadIcon*</span> image asset
- Page upload state icon background color
  - Successful upload &#8594; `GiniBankConfiguration.multipagePageSuccessfullUploadIconBackgroundColor`
  - Failed upload &#8594; `GiniBankConfiguration.multipagePageFailureUploadIconBackgroundColor`
- Page circle indicator color &#8594; `GiniBankConfiguration.indicatorCircleColor` using `GiniColor` with dark mode and light mode colors
- Page indicator color &#8594; `GiniBankConfiguration.multipagePageIndicatorColor` 
- Page background color &#8594; `GiniBankConfiguration.multipagePageBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Page selected indicator color &#8594; `GiniBankConfiguration.multipagePageSelectedIndicatorColor`
- Page draggable icon tint color &#8594; `GiniBankConfiguration.multipageDraggableIconColor`

##### 4. Bottom container
- Background color &#8594; `GiniBankConfiguration.multipagePagesContainerAndToolBarColor` using `GiniColor` with dark mode and light mode colors
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
	  - Title &#8594; `GiniBankConfiguration.navigationBarAnalysisTitleBackButton`

##### 2. PDF Information view
- Text color &#8594; `GiniBankConfiguration.analysisPDFInformationTextColor`
- Background color &#8594; `GiniBankConfiguration.analysisPDFInformationBackgroundColor`

##### 3. Loading view
- Indicator color &#8594; `GiniBankConfiguration.analysisLoadingIndicatorColor` (Only with PDFs)
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
	  - Title &#8594; `GiniBankConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Supported format cells
- Supported fortmats icon &#8594; <span style="color:#009EDF">*supportedFormatsIcon*</span> image asset
- Supported formats icon color &#8594; `GiniBankConfiguration.supportedFormatsIconColor`
- Non supported fortmats icon &#8594; <span style="color:#009EDF">*nonSupportedFormatsIcon*</span> image asset
- Non supported formats icon color &#8594; `GiniBankConfiguration.nonSupportedFormatsIconColor`

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
	  - Title &#8594; `GiniBankConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Header
- Text &#8594; <span style="color:#009EDF">*ginicapture.help.openWithTutorial.collectionHeader*</span> localized string

##### 2. Open with steps
- App name &#8594; `GiniBankConfiguration.openWithAppNameForTexts`
- Step indicator color &#8594; `GiniBankConfiguration.stepIndicatorColor`
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
<center><img src="img/Customization guide/Tips for photos.png" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginicapture.noresults.title*</span> localized string

##### 2. Header container
- Text &#8594; <span style="color:#009EDF">*ginicapture.noresults.warningHelpMenu*</span> localized string

##### 3. Capturing tip images
- Tip 1 image &#8594; <span style="color:#009EDF">*captureSuggestion1*</span> image asset
- Tip 2 image &#8594; <span style="color:#009EDF">*captureSuggestion2*</span> image asset
- Tip 3 image &#8594; <span style="color:#009EDF">*captureSuggestion3*</span> image asset
- Tip 4 image &#8594; <span style="color:#009EDF">*captureSuggestion4*</span> image asset
- Tip 5 image &#8594; <span style="color:#009EDF">*captureSuggestion5*</span> image asset

##### 4. Go to camera button
- Background color &#8594; `GiniBankConfiguration.noResultsBottomButtonColor`
- Text color &#8594; `GiniBankConfiguration.noResultsBottomButtonTextColor`
- Corner radius &#8594; `GiniBankConfiguration.noResultsBottomButtonCornerRadius`
- Back button
  - With image and title
      - Image &#8594; <span style="color:#009EDF">*cameraIcon*</span> image asset
      - Title &#8594; <span style="color:#009EDF">*ginicapture.noresults.gotocamera*</span> localized string
      
## Gallery album screen

<br>
<center><img src="img/Customization guide/Gallery album.jpg" height="500"/></center>
</br>

##### 1. Selected image
- Selected item check color &#8594; `GiniBankConfiguration.galleryPickerItemSelectedBackgroundCheckColor`
- Background color &#8594; `GiniBankConfiguration.galleryScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

## Onboarding screens

<br>
<center><img src="img/Customization guide/Onboarding.png" height="500"/></center>
</br>

##### 1. Background
- Background Color &#8594; `GiniBankConfiguration.onboardingScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 2. Image
- Page image &#8594; <span style="color:#009EDF">*onboardingPage**</span> image asset

##### 3. Text
- Color &#8594; `GiniBankConfiguration.onboardingTextColor` using `GiniColor` with dark mode and light mode colors

##### 4. Page indicator
- Color &#8594; `GiniBankConfiguration.onboardingPageIndicatorColor` using `GiniColor` with dark mode and light mode colors

##### 5. Current page indicator
- Color &#8594; `GiniBankConfiguration.onboardingCurrentPageIndicatorColor` using `GiniColor` with dark mode and light mode colors
- Alpha &#8594; `GiniBankConfiguration.onboardingCurrentPageIndicatorAlpha` sets alpha to the `GiniBankConfiguration.onboardingCurrentPageIndicatorColor`

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
	  - Title &#8594; `GiniBankConfiguration.navigationBarHelpMenuTitleBackToCameraButton`

##### 2. Table View Cells
- Background color &#8594; `GiniBankConfiguration.helpScreenCellsBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 3. Background
- Background color &#8594; `GiniBankConfiguration.helpScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 4. Additional help menu items
- Custom help menu items &#8594; `GiniBankConfiguration.customMenuItems` an array of `HelpMenuViewController.Item` objects

## No results screen

<br>
<center><img src="img/Customization guide/No results.png" height="500"/></center>
</br>

##### 1. Warning container
- Background color &#8594; `GiniBankConfiguration.noResultsWarningContainerIconColor`
- Image &#8594; <span style="color:#009EDF">*warningNoResults*</span> image asset
- Title &#8594; <span style="color:#009EDF">*ginicapture.noresults.warning*</span> localized string

##### 2. Tips for photo collection
- Header title &#8594; <span style="color:#009EDF">*ginicapture.noresults.collection.header*</span> localized string

Overriding tips images below will lead to the changes on the [Capturing tips screen](#capturing-tips-screen).

- Tip 1 image &#8594; <span style="color:#009EDF">*captureSuggestion1*</span> image asset
- Tip 2 image &#8594; <span style="color:#009EDF">*captureSuggestion2*</span> image asset
- Tip 3 image &#8594; <span style="color:#009EDF">*captureSuggestion3*</span> image asset
- Tip 4 image &#8594; <span style="color:#009EDF">*captureSuggestion4*</span> image asset
- Tip 5 image &#8594; <span style="color:#009EDF">*captureSuggestion5*</span> image asset

##### 3. Back to camera button
- Background color &#8594; `GiniBankConfiguration.noResultsBottomButtonColor`
- Text color &#8594; `GiniBankConfiguration.noResultsBottomButtonTextColor`
- Corner radius &#8594; `GiniBankConfiguration.noResultsBottomButtonCornerRadius`
- Back button
  - With image and title
      - Image &#8594; <span style="color:#009EDF">*cameraIcon*</span> image asset
      - Title &#8594; <span style="color:#009EDF">*ginicapture.noresults.gotocamera*</span> localized string

## Albums screen

<br>
<center><img src="img/Customization guide/Albums screen.png" height="500"/></center>
</br>

##### 1. Select more photos button
- Text color &#8594; `GiniBankConfiguration.albumsScreenSelectMorePhotosTextColor` using `GiniColor` with dark mode and light mode colors
- Title &#8594; <span style="color:#009EDF">*ginicapture.albums.selectMorePhotosButton*</span> localized string

## Return assistant

### Onboarding screen

<br>
<center><img src="img/Customization guide/Digital Invoice Onboarding Screen.jpg" height="500"/></center>
</br>

##### 1. Background
- Color &#8594; `GiniBankConfiguration.digitalInvoiceBackgroundColor`

##### 2. Title
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.onboarding.text1*</span> localized string
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceOnboardingFirstLabelTextFont` 
- Color &#8594; `GiniBankConfiguration.digitalInvoiceOnboardingTextColor`

##### 3. Illustration
- Image &#8594; <span style="color:#009EDF">*digital_invoice_onboarding_icon*</span> image asset

##### 4. Message
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.onboarding.text2*</span> localized string
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceOnboardingSecondLabelTextFont`
- Color &#8594; `GiniBankConfiguration.digitalInvoiceOnboardingTextColor`

##### 5. "Done" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.onboarding.donebutton*</span> localized string
- Background color &#8594; `GiniBankConfiguration.digitalInvoiceOnboardingDoneButtonBackgroundColor`
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceOnboardingDoneButtonTextColor`
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceOnboardingDoneButtonTextFont`

##### 6. "Don't Show Again" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.onboarding.hidebutton*</span> localized string
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceOnboardingHideButtonTextColor`
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceOnboardingHideButtonTextFont`

### Info box

<br>
<center><img src="img/Customization guide/Digital Invoice Check Items Info Box.jpg" height="500"/></center>
</br>

##### 1. Background
- Color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewBackgroundColor`

##### 2. Title and message
- Title
  - Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.warningtoptitle*</span> localized string
  - Font &#8594;  `GiniBankConfiguration.digitalInvoiceInfoViewTopLabelFont` 
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewWarningLabelsTextColor`
- Message
  - Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.warningmiddletext*</span> localized string
  - Font &#8594;  `GiniBankConfiguration.digitalInvoiceInfoViewMiddleLabelFont` 
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewWarningLabelsTextColor`

##### 3. Expand/collapse button
- Image &#8594; <span style="color:#009EDF">*chevron-up-icon*</span> image asset
- Tint color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewChevronImageViewTintColor`

##### 4. Illustration
- Image &#8594; <span style="color:#009EDF">*ra-warning-illustration*</span> image asset

##### 5. Bottom message
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.warningbottomtext*</span> localized string
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceInfoViewBottomLabelFont` 
- Color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewWarningLabelsTextColor`

##### 6. "OK" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.warningleftbuttontitle*</span> localized string
- Background color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewLeftButtonBackgroundColor`
- Border color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewLeftButtonBorderColor`
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewLeftkButtonTitleColor`
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceInfoViewButtonsFont`

##### 7. "Skip" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.warningrightbuttontitle*</span> localized string
- Background color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewRightButtonBackgroundColor`
- Border color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewRightButtonBorderColor`
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceInfoViewRightButtonTitleColor`
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceInfoViewButtonsFont`

### Digital invoice screen

<br>
<center><img src="img/Customization guide/Digital Invoice Screen.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.screentitle*</span> localized string
- Help button image &#8594; <span style="color:#009EDF">*infoIcon*</span> image asset

##### 2. Background
- Color &#8594; `GiniBankConfiguration.digitalInvoiceBackgroundColor`

##### 3. Line item index
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.items*</span> localized string.  
  Please include two decimal format arguments:
  1. Current index: `%d`
  2. Total count: `%d`
- Accessibility label &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.items.accessibilitylabel*</span> localized string.  
  Please include two decimal format arguments:
  1. Current index: `%d`
  2. Total count: `%d`
- Font &#8594;  `GiniBankConfiguration.lineItemCountLabelFont`
- Color &#8594; `GiniBankConfiguration.lineItemCountLabelColor`

##### 4. Line item edit button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.editbutton*</span> localized string
- Icon &#8594; <span style="color:#009EDF">*editIcon*</span> image asset
- Tint color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemEditButtonTintColor`
- Font &#8594;  `GiniBankConfiguration.digitalInvoiceLineItemEditButtonTitleFont`

##### 5. Line item card
- Background
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemsBackgroundColor`
- Border
  - Color &#8594; `GiniBankConfiguration.lineItemBorderColor`
- Toggle switch
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemToggleSwitchTintColor`
- Item name
  - Font &#8594;  `GiniBankConfiguration.digitalInvoiceLineItemNameFont`
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemNameColor`
- Quantity
  - Font &#8594;  `GiniBankConfiguration.digitalInvoiceLineItemQuantityFont`
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemQuantityColor`
- Price
  - Main unit
    - Font &#8594;  `GiniBankConfiguration.digitalInvoiceLineItemPriceMainUnitFont`
    - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemPriceColor`
  - Fractional unit
    - Font &#8594;  `GiniBankConfiguration.digitalInvoiceLineItemPriceFractionalUnitFont`
    - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemPriceColor`
  - Accessibility label &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.total.accessibilitylabel*</span> localized string
- Delete button (shown only for manually added line items)
  - Icon &#8594; <span style="color:#009EDF">*garbage-bin-icon*</span> image asset
  - Tint color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemDeleteButtonTintColor`
- Disabled state
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemsDisabledColor`

##### 6. Additional costs
- Label
  - Font &#8594; `GiniBankConfiguration.digitalInvoiceAddonLabelFont`
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceAddonLabelColor`
- Price
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceAddonPriceColor`
  - Main unit font &#8594;  `GiniBankConfiguration.digitalInvoiceAddonPriceMainUnitFont`
  - Fractional unit font &#8594;  `GiniBankConfiguration.digitalInvoiceAddonPriceFractionalUnitFont`

##### 7. "Add article" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.total.addArticleButtonTitle*</span> localized string
- Icon &#8594; <span style="color:#009EDF">*plus-icon*</span> image asset
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceFooterAddArticleButtonTintColor`
- Font &#8594; `GiniBankConfiguration.digitalInvoiceFooterAddArticleButtonTitleFont`

##### 8. Total price
- Caption 
  - Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.totalcaptionlabeltext*</span> localized string
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceTotalCaptionLabelTextColor`
  - Font &#8594; `GiniBankConfiguration.digitalInvoiceTotalCaptionLabelFont`
- Explanation 
  - Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.totalexplanationlabeltext*</span> localized string
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceTotalExplanationLabelTextColor`
  - Font &#8594; `GiniBankConfiguration.digitalInvoiceTotalExplanationLabelFont`
- Price
  - Color &#8594; `GiniBankConfiguration.digitalInvoiceTotalPriceColor`
  - Main unit font &#8594;  `GiniBankConfiguration.digitalInvoiceTotalPriceMainUnitFont`
  - Fractional unit font &#8594;  `GiniBankConfiguration.digitalInvoiceTotalPriceFractionalUnitFont`
  - Accessibility label &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.total.accessibilitylabel*</span> localized string

##### 9. Footer message
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.footermessage*</span> localized string
- Text color &#8594; `GiniBankConfiguration.digitalInvoiceFooterMessageTextColor`
- Font &#8594; `GiniBankConfiguration.digitalInvoiceFooterMessageTextFont`

##### 10. "Pay" button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.paybuttontitle*</span> localized string.  
  Please include two decimal format arguments:
  1. Selected items count: `%d`
  2. Total count: `%d`
- Accessibility label &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.paybuttontitle.accessibilitylabel*</span> localized string.  
  Please include two decimal format arguments:
  1. Selected items count: `%d`
  2. Total count: `%d`
- Background color &#8594;  `GiniBankConfiguration.payButtonBackgroundColor`
- Title color &#8594; `GiniBankConfiguration.payButtonTitleTextColor`
- Font &#8594;  `GiniBankConfiguration.payButtonTitleFont`

##### 11. "Skip" Button
- Title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.skipbuttontitle*</span> localized string
- Background color &#8594;  `GiniBankConfiguration.skipButtonBackgroundColor`
- Border color &#8594;  `GiniBankConfiguration.skipButtonBorderColor`
- Title color &#8594; `GiniBankConfiguration.skipButtonTitleTextColor`
- Font &#8594;  `GiniBankConfiguration.skipButtonTitleFont`

### Return reason action sheet

<br>
<center><img src="img/Customization guide/Digital Invoice Return Reason Picker.jpg" height="500"/></center>
</br>

##### 1. Title
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.deselectreasonactionsheet.message*</span> localized string

##### 2. "Cancel" button
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.deselectreasonactionsheet.action.cancel*</span> localized string

### Info dialog

<br>
<center><img src="img/Customization guide/Digital Invoice Info Dialog.jpg" height="500"/></center>
</br>

##### 1. Title
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.whatisthisactionsheet.title*</span> localized string

##### 2. Message
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.whatisthisactionsheet.message*</span> localized string

##### 3. "Helpful" button
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.whatisthisactionsheet.action.helpful*</span> localized string

##### 4. "Not helpful" button
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.whatisthisactionsheet.action.nothelpful*</span> localized string

##### 5. "Cancel" button
- Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.whatisthisactionsheet.action.cancel*</span> localized string

### Edit line item screen

<br>
<center><img src="img/Customization guide/Digital Invoice Edit Line Item.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Save button title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.savebutton*</span> localized string

##### 2. Background
- Color &#8594; `GiniBankConfiguration.lineItemDetailsBackgroundColor`

##### 3. Checkmark
- Color &#8594; `GiniBankConfiguration.digitalInvoiceLineItemToggleSwitchTintColor`
- Label text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.checkmark.label*</span> [plural](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/StringsdictFileFormat/StringsdictFileFormat.html) localized string.  
  Please include a decimal format argument for the quantity integer (e.g. `%d Artikel ausgewählt`).
- Accessibility label
    - Select &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.checkmarkbutton.select.accessibilitylabel*</span> localized string
    - Deselect &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.checkmarkbutton.deselect.accessibilitylabel*</span> localized string

##### 4. 5. 6. Text fields: name, quantity, price
- Item name field title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.itemnametextfieldtitle*</span> localized string
- Quantity field title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.quantitytextfieldtitle*</span> localized string
- Price field title &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.pricetextfieldtitle*</span> localized string
- Field title
  - Color &#8594; `GiniBankConfiguration.lineItemDetailsDescriptionLabelFont`
  - Font &#8594; `GiniBankConfiguration.lineItemDetailsDescriptionLabelColor`
- Field content
  - Color &#8594; `GiniBankConfiguration.lineItemDetailsContentLabelColor`
  - Font &#8594; `GiniBankConfiguration.lineItemDetailsContentLabelFont`
- Field highlighted color &#8594; `GiniBankConfiguration.lineItemDetailsContentHighlightedColor`

##### 7. Multiplication symbol
- Color &#8594; `GiniBankConfiguration.lineItemDetailsContentLabelFont`
- Font &#8594; `GiniBankConfiguration.lineItemDetailsContentLabelColor`
- Accessibility label &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.multiplication.accessibilitylabel*</span> localized string

##### 8. Total price
- Label
  - Text &#8594; <span style="color:#009EDF">*ginibank.digitalinvoice.lineitem.totalpricetitle*</span> localized string
  - Color &#8594; `GiniBankConfiguration.lineItemDetailsDescriptionLabelFont`
  - Font &#8594; `GiniBankConfiguration.lineItemDetailsDescriptionLabelColor`
- Price
  - Color &#8594; `GiniBankConfiguration.lineItemDetailsContentLabelColor`
  - Main unit font &#8594;  `GiniBankConfiguration.lineItemDetailsTotalPriceMainUnitFont`
  - Fractional unit font &#8594;  `GiniBankConfiguration.lineItemDetailsTotalPriceFractionalUnitFont`
