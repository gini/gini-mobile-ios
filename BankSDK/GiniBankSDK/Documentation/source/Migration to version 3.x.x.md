Migrate from the Gini Bank SDK 1.x.x to 3.x.x
=================================================

# Breaking changes

In version 3.0.0 we modernized our UI. In addition, we simplified how the UI
is customized, introduced centralized customization for the color pallete, typograhy.
We also removed the Component API integration option and unified the public API of the SDK and introduced an easier way to customize certain parts of the UI.

`GiniBankConfiguration` is a singleton now.
You don't need to create a new instance of `GiniBankConfiguration` just use `GiniBankConfiguration.shared` instead.

Please, find more details in [Getting started](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/getting-started.html).

# Migrate from Compoment API

The Component API allowed more UI customization options at the cost of a more difficult integration and maintenance. It
was based on the view controllers, and you had to manage navigation between them and also update the navigation whenever we introduced
breaking changes.

Maintaining the Component API along with the simpler Screen API required an increasing amount of effort as we added new
features. We decided therefore to unify both APIs and introduce the ability to inject fully custom UI elements.

The major benefit of the Component API was the ability to use a custom navigation bar. Via
`GiniBankConfiguration.shared.customNavigationController` that is still possible with the new public API.

The following steps will help you migrate to the new public API:

* Configure the SDK the same way as before by using `GiniBankConfiguration`.
* If you used a custom navigation bar, then you can now pass `UINavigationViewController` to `GiniBankConfiguration.shared.customNavigationController`.
* The SDK provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.

```swift
// MARK: - Default networking
        let viewController = GiniCapture.viewController(withClient: client,
                                                        importedDocuments: visionDocuments,
                                                        configuration: visionConfiguration,
                                                        resultsDelegate: self,
                                                        documentMetadata: documentMetadata,
                                                        api: .default,
                                                        userApi: .default,
                                                        trackingDelegate: self)
// MARK: - Custom networking
        let viewController = GiniCapture.viewController(importedDocuments: visionDocuments,
                                                        configuration: visionConfiguration,
                                                        resultsDelegate: self,
                                                        documentMetadata: documentMetadata,
                                                        trackingDelegate: trackingDelegate,
                                                        networkingService: self)
```

* Handling the analysis results and receiving the extracted information (error or cancellation) can be handled though `GiniCaptureResultsDelegate` protocol implementation.
* You can also provide your own networking by implementing the `GiniCaptureNetworkService` and `GiniCaptureResultsDelegate` protocols. Pass your instances to the `UIViewController` initialiser of GiniCapture as shown below.
* Remove all code related to interacting with the SDK's specific view controllers. From now on the entry point is the `UIViewController` and customization happens through `GiniBankConfiguration` and via overriding of images and color resources.
* Use the new UI customization options and follow the [Customization guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/customization-guide.html) to adapt the look of the new UI.

# Migrate from Screen API

The new public API is based on the Screen API, so you only need to use the new UI customization options and follow the [Customization guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/customization-guide.html) to adapt the look of the new UI.

# Overview of New UI Customization Options

To simplify UI customization we introduced global customization options. There is no need to customize each screen separately anymore.

## Colors

We are providing a global color palette `GiniColors.xcassets` which you are free to override. The custom colors will be then applied on all screens.
You can find the names of the colors in [GiniColors.xcassets](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/GiniColors.xcassets).

 You can view our color palette here:

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D14%253A355%26t%3D6sAk7LGf1mi3zV9L-1" allowfullscreen></iframe>

## Typography

We provide a global typography based on text appearance styles from `UIFont.TextStyle`. 

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D123%253A2326%26t%3D6sAk7LGf1mi3zV9L-1" allowfullscreen></iframe>

To override them in your application please use `GiniBankConfiguration.updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle)`. For example:

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

# UI Elements

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

**Note**:  The top navigation bar will still be used, but its  functionality will be limited to showing the screen's title and
an optional close button. Please inject a custom top navigation bar if your design requires it even if you have enabled the bottom navigation bar.

# Migrate to the new UI

## Onboarding screens

The new onboarding screen uses the global UI customization options. You can discard the old screen specific
customizations.

Images and text are onboarding page specific and need to be customized for each page.

[here][https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/features.html#onboarding] and [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=243%3A3305&t=6sAk7LGf1mi3zV9L-1).

### Breaking Changes

#### Setting Custom Onboarding Pages

The `OnboardingPage` struct was changed to also allow setting a title for the page and inject a view for the
illustration.

If you are setting custom onboarding pages, then you have to create the `OnboardingPage` as shown in the example
below:

```swift
    configuration.customOnboardingPages = [OnboardingPage(imageName: "captureSuggestion1", title: "Page 1", description: "Description for page 1")]
```

### New Features

#### Custom Illustration Views

By implementing the `OnboardingIllustrationAdapter` interface and passing it to either `GiniCapture` or the
`OnboardingPage` constructor you can inject any custom view for the illustration.

If you need to animate the illustrations on the onboarding pages implement the `OnboardingIllustrationAdapter` interface to inject a view that can animate images (e.g., `Lottie`) and pass it to the relevant onboarding illustration adapter setters (e.g., 
`onboardingAlignCornersIllustrationAdapter`,
`onboardingLightingIllustrationAdapter`,
`onboardingMultiPageIllustrationAdapter`,
`onboardingQRCodeIllustrationAdapter`)
 when configuring the `GiniBankConfiguration.shared` instance.

## Camera screen

The new camera screen uses the global UI customization options. You can discard the old screen specific
customizations.

### New Features

#### QR Code only

During QR Code only mode the capture and import controls will be hidden from the camera screen.

For enabling QR code only mode the both flags `GiniBankConfiguration.shared.qrCodeScanningEnabled` and `GiniBankConfiguration.shared.onlyQRCodeScanningEnabled` should be `true`.

## Help screens

The new help screens use the global UI customization options. You can discard the old screen specific customizations.

### Breaking Changes

String keys changed:
`ginicapture.help.menu.firstItem` → `ginicapture.help.menu.tips`
`ginicapture.help.menu.secondItem`→ `ginicapture.help.menu.formats`
`ginicapture.help.menu.thirdItem` → `ginicapture.help.menu.import`

### New Features

#### Bottom navigation bar

You can show a bottom navigation bar by passing true to `GiniBankConfiguration.shared.bottomNavigationBarEnabled`. There is a default implementation, but you can also use
your own by implementing the `HelpBottomNavigationBarAdapter` interface and passing it to `GiniBankConfiguration.shared.helpNavigationBarBottomAdapter`.

You can find more details [here][https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/features.html#help-screen-customization] and [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=141%3A2328&t=6sAk7LGf1mi3zV9L-1).

## Analysis screen

The new analysis screen uses the global UI customization options. You can discard the old screen specific customizations.

### Breaking Changes

String keys removed:
`ginicapture.analysis.suggestion.header`

The following string keys now represent suggestion titles with new keys added for describing the tips.
`ginicapture.analysis.suggestion.1`
`ginicapture.analysis.suggestion.2`
`ginicapture.analysis.suggestion.3`
`ginicapture.analysis.suggestion.4`
`ginicapture.analysis.suggestion.5`

### New Features

#### Custom loading indicator

You can show a custom loading indicator with custom animation support on the center of the screen.
Your custom loading indicator should implement `CustomLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.customLoadingIndicator`.
This loading indicator is also used on the `Camera screen` when loading data for a valid QR code.

You can find more details [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=501%3A7494&t=6sAk7LGf1mi3zV9L-1).

## Review screen

The new review screen uses the global UI customization options. You can discard the old screen specific customizations.

### Breaking Changes

We unified UI for the single page and multi pages options.
We removed rotation and reorder functionalities.
Tips view was removed as well.

### New Features

#### Custom loading indicator

You can show a custom loading indicator with custom animation support on the process button of the screen.
Your custom loading indicator should implement `OnButtonLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.onButtonLoadingIndicator`.

#### Bottom navigation bar

You can show a bottom navigation bar by passing true to `GiniBankConfiguration.shared.bottomNavigationBarEnabled`. There is a default implementation, but you can also use
your own by implementing the `ReviewScreenBottomNavigationBarAdapter` interface and passing it to `GiniBankConfiguration.shared.reviewNavigationBarBottomAdapter`.

You can find more details [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=261%3A8256&t=6sAk7LGf1mi3zV9L-1).

## No results screen

The new no results screen uses the global UI customization options. You can discard the old screen specific
customizations.

### Breaking Changes

#### Removed localization keys:

`ginicapture.noresults.warning`
`ginicapture.noresults.collection.header`
`ginicapture.noresults.gotocamera`
`ginicapture.noresults.warningHelpMenu`

### New features

#### New localization keys:

`ginicapture.noresult.enterManually`
`ginicapture.noresult.retakeImages`

#### Option to enter details manually

You can show your own UI for data input if an error occurred and the user clicks the "Enter manually" button on the error screen.
For this you must to implement `GiniCaptureResultsDelegate.giniCaptureDidEnterManually() `.

You can find more details [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=263%3A6989&t=7wXW9XyhTUcmp5sk-1) and [here](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/customization-guide.html#no-result-screen).

## Error screen

The new error screen uses the global UI customization options.

### Breaking Changes

Showing errors during usage of the SDK was changed from snackbar to a whole new screen.

### New Features

#### New UI

The new error screen gives options to retake photos or enter details manually and displays errors with more detailed description.

You can find more details [here](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/customization-guide.html#error-screen).

#### Option to enter details manually

You can show your own UI for data input if an error occured and the user clicks the "Enter manually" button on the error screen.
For this you must to implement `GiniCaptureResultsDelegate.giniCaptureDidEnterManually() `.

You can find more details [here](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/features.html#error-screen-customization) and [here]((https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta06/customization-guide.html#error-screen).
