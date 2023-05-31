Features
=========

The Gini Bank SDK provides various features you can enable and configure. All the features are configured during
through `GiniBankConfiguration.shared` instance. Specifically the `GiniBankConfiguration` is used to configure the Gini
Bank SDK.

**Note**: Some features require additional contractual agreements and may not be used without prior confirmation. Please get in touch with us in case you are not sure which features your contract includes.

The following sections list all the features along with the related configuration options.

# Document Capture

This is the core feature of the Gini Bank SDK. It enables your app to capture documents with the camera and prepares
them to be analyzed by the Gini Bank API.

# Custom UI Elements

Certain elements of the UI can now be fully customized via UI injection. It utilizes view adapter interfaces which you
can implement and pass to `GiniBankConfiguration` when configuring the SDK. These interfaces declare the contract the injected
view has to fulfill and allow the SDK to ask for your view instance when needed.

## Top Navigation Bar

To inject your own navigation bar view you need to pass your navigation view controller to 
`GiniBankConfiguration.shared.customNavigationController`.
The view from the custom navigation view controller will then be displayed on all screens as the top navigation bar.

## Bottom Navigation Bar

You can opt to show a bottom navigation bar. To enable it pass `true` to
`GiniBankConfiguration.shared.bottomNavigationBarEnabled`.

**Note**:  The top navigation bar will still be used, but its    functionality will be limited to showing the screen's title and
an optional close button. Please inject a custom top navigation bar if your design requires it even if you have enabled the bottom navigation bar.

# Onboarding

The onboarding feature presents essential information to the user on how to best capture documents.

You can customize the onboarding in the following ways:

* Disable showing the onboarding at first run:
   By default the onboarding is shown at first run. To disable this pass `false` to
   `GiniBankConfiguration.shared.onboardingShowAtFirstLaunch`.

* Customize the onboarding pages:
   If you wish to show different onboarding pages then pass a list of `OnboardingPage` structs to `GiniBankConfiguration.shared.customOnboardingPages`.

* Force show the onboarding:
   If you wish to show the onboarding after the first run then pass `true` to
   `GiniBankConfiguration.shared.onboardingShowAtLaunch`.

* Animate illustrations by injecting custom views:
   If you need to animate the illustrations on the onboarding pages implement the `OnboardingIllustrationAdapter`
   interface to inject a view that can animate images (e.g., `Lottie`) and
   pass it to the relevant onboarding illustration adapter setters (e.g.,
   `onboardingAlignCornersIllustrationAdapter`,`onboardingLightingIllustrationAdapter`,`onboardingMultiPageIllustrationAdapter`,`onboardingQRCodeIllustrationAdapter`) when configuring the `GiniBankConfiguration.shared` instance.

# Single Page

By default, the Gini Bank SDK is configured to capture single page documents. No further configuration is required for
this.

# Multi-Page

The multi-page feature allows the SDK to capture documents with multiple pages.

To enable this simply pass `true` to `GiniBankConfiguration.shared.multipageEnabled`.

# Camera

- Enable the flash toggle button:
To allow users toggle the camera flash pass `true` to `GiniBankConfiguration.shared.flashToggleEnabled`.

- Turn off flash by default:
Flash is on by default, and you can turn it off by passing `false` to `GiniBankConfiguration.shared.flashOnByDefault`.

 # QR Code Scanning

When a supported QR code is detected with valid payment data, the QR Code will be processed automatically without any further user interaction.
The QR Code scanning may be triggered directly without the need to analyze the document.

If the QR code does not have a supported payment format then a popup informs the user that a QR code was detected, but it cannot be used.

Please find more information in the [QR Code scanning guide](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/qr-code-scanning-guide.html).

## QR Code Only

During QR Code only mode the capture and import controls will be hidden from the camera screen.

For enabling QR code only mode the both flags `GiniBankConfiguration.shared.qrCodeScanningEnabled` and `GiniBankConfiguration.shared.onlyQRCodeScanningEnabled` should be `true`.

# Document Import

This feature enables the Gini Bank SDK to import documents from the camera screen. When it's enabled an additional button is shown next to the camera trigger. Using this button allows the user to pick either an image or a pdf from the device.

Please find more information in the [Import PDFs and images guide](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/import-pdfs-and-images-guide.html).

# Open with

The `Open with` feature allows importing of files from other apps via iOS `share` functionality.

Please find more information in the [Open with guide](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/open-with-guide.html).

# Help screen customization

You can show your own help screens in the Gini Bank SDK.
You can pass the title and view controller for each screen to the
`GiniBankConfiguration.shared.customMenuItems` using a list of `HelpMenuItem` structs:

``` swift

        let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())

        configuration.customMenuItems = [customMenuItem]
 ```           
The example implementation is available [here](https://github.com/gini/gini-mobile-ios/blob/GiniBankSDK%3B3.1.1/BankSDK/GiniBankSDKExample/GiniBankSDKExample/CustomMenuItemViewController.swift).

You can also disable the supported formats help screen by passing `false` to
`GiniBankConfiguration.shared.shouldShowSupportedFormatsScreen`.

# Review screen customization

You can show a custom loading indicator with custom animation support on the process button.
Your custom loading indicator should implement `OnButtonLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.onButtonLoadingIndicator`.

The example implementation is available [here](https://github.com/gini/gini-mobile-ios/blob/GiniBankSDK%3B3.1.1/BankSDK/GiniBankSDKExample/GiniBankSDKExample/CustomLoadingIndicator.swift#L36).

# Analysis screen customization

You can show a custom loading indicator with custom animation support.
Your custom loading indicator should implement `CustomLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.customLoadingIndicator`.

The example implementation is available [here](https://github.com/gini/gini-mobile-ios/blob/GiniBankSDK%3B3.1.1/BankSDK/GiniBankSDKExample/GiniBankSDKExample/CustomLoadingIndicator.swift).

# No result screen customization

You can show your own UI if an error occured and the user chooses to enter details manually. For this you must to implement `GiniCaptureResultsDelegate.giniCaptureDidEnterManually() `.

The buttom "Retake images" will be shown only if you took or imported images.

# Error screen customization

You can show your own UI if an error occured and the user chooses to enter details manually. For this you must to implement `GiniCaptureResultsDelegate.giniCaptureDidEnterManually() `.

The buttom "Retake images" will be shown only if you took or imported images.

# Event Tracking

You have the possibility to track various events which occur during the usage of the Gini Bank SDK.

Please find more information in the [Event tracking guide](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/event-tracking-guide.html).

# Error Logging

The SDK logs errors to the Gini Bank API when the default networking implementation is used. See the `Default networking` implementation in the [Integration](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/integration.html).

Please find more details [here](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.1/error-logging-guide.html).

## Return Assistant

The return assistant feature allows your users to view and edit payable items in an invoice. The total amount is
updated to be the sum of only those items which the user opts to pay.

To enable this feature simply set ``returnAssistantEnabled`` to ``true`` in the ``GiniBankConfiguration``: 

```swift
let configuration = GiniBankConfiguration.shared
configuration.returnAssistantEnabled = true
```

The Gini Bank SDK will show the return assistant automatically if the invoice contained payable items and will update the extractions returned to your app according to the user’s changes.

The ``amountToPay`` extraction is updated to be the sum of the items the user decided to pay. It includes discounts and
additional charges that might be present on the invoice.

The extractions related to the return assistant are stored in the ``lineItems`` field of the ``AnalysisResult``. See the
Gini Bank API's [documentation](https://pay-api.gini.net/documentation/#return-assistant-extractions) to learn about the
return assistant's extractions.

# Accessibility

During the development, we’ve followed the best practices from [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/foundations/accessibility).

## The SDK conforms to the following accessibility features:

• All UI elements have clear and concise descriptions, ensuring that users who rely on VoiceOver are able to navigate the app with ease.

• The UI works seamlessly even when the system text size is increased.
 
• All elements have a minimum size of 44pt x 44pt, making it easy for users to interact with the app even if they have limited dexterity.

• The SDK utilizes the OS font size settings, making it easy for users to adjust the font size according to their preferences. This ensures that all text is easily legible, regardless of a user's individual needs.

• The app features an adequate contrast ratio, ensuring that all users can easily read and distinguish text from the background.

### Warning

When customizing the SDK’s UI you can override accessibility conformance by changing colors, images and injecting custom UI elements. We strongly advise you to make your customizations accessibility friendly.
