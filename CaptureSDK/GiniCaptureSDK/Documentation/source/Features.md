Features
=========

The Gini Capture SDK provides various features you can enable and configure. All the features are configured during
through `GiniConfiguration.shared` instance. Specifically the `GiniConfiguration` is used to configure the Gini
Capture SDK.

**Note**: Some features require additional contractual agreements and may not be used without prior confirmation. Please get in touch with us in case you are not sure which features your contract includes.

The following sections list all the features along with the related configuration options.

# Document Capture

This is the core feature of the Gini Capture SDK. It enables your app to capture documents with the camera and prepares
them to be analyzed by the Gini Bank API.

## Custom UI Elements

Certain elements of the UI can now be fully customized via UI injection. It utilizes view adapter interfaces which you
can implement and pass to `GiniConfiguration` when configuring the SDK. These interfaces declare the contract the injected
view has to fulfill and allow the SDK to ask for your view instance when needed.

### Top Navigation Bar

To inject your own navigation bar view you need to pass your navigation view controller to 
`GiniConfiguration.shared.customNavigationController`.
The view from the custom navigation view controller will then be displayed on all screens as the top navigation bar.

### Bottom Navigation Bar

You can opt to show a bottom navigation bar. To enable it pass `true` to
`GiniConfiguration.shared.bottomNavigationBarEnabled`.

**Note**:  The top navigation bar will still be used, but its    functionality will be limited to showing the screen's title and
an optional close button. Please inject a custom top navigation bar if your design requires it even if you have enabled the bottom navigation bar.

## Onboarding

The onboarding feature presents essential information to the user on how to best capture documents.

You can customize the onboarding in the following ways:

* Disable showing the onboarding at first run:
   By default the onboarding is shown at first run. To disable this pass `false` to
   `GiniConfiguration.shared.onboardingShowAtFirstLaunch`.

* Customize the onboarding pages:
   If you wish to show different onboarding pages then pass a list of `OnboardingPageNew` structs to `GiniConfiguration.shared.customOnboardingPages`.

* Force show the onboarding:
   If you wish to show the onboarding after the first run then pass `true` to
   ``GiniConfiguration.shared.onboardingShowAtLaunch`.

* Animate illustrations by injecting custom views:
   If you need to animate the illustrations on the onboarding pages implement the `OnboardingIllustrationAdapter`
   interface to inject a view that can animate images (e.g., `Lottie`) and
   pass it to the relevant onboarding illustration adapter setters (e.g.,
   `onboardingAlignCornersIllustrationAdapter`,`onboardingLightingIllustrationAdapter`,`onboardingMultiPageIllustrationAdapter`,`onboardingQRCodeIllustrationAdapter`) when configuring the `GiniConfiguration.shared` instance.

## Single Page

By default, the Gini Capture SDK is configured to capture single page documents. No further configuration is required for
this.

## Multi-Page

The multi-page feature allows the SDK to capture documents with multiple pages.

To enable this simply pass `true` to `GiniConfiguration.shared.multipageEnabled`.

## Camera

* Enable the flash toggle button:
   To allow users toggle the camera flash pass `true` to `GiniConfiguration.shared.flashToggleEnabled`.

* Turn off flash by default:
   Flash is on by default, and you can turn it off by passing `false` to `GiniConfiguration.shared.flashOnByDefault`.