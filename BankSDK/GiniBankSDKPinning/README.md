
<p align="center">
<img src="./GiniPayBank_Logo.png" width="250">
</p>

# Gini Bank SDK for iOS
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)]()
[![Swift package manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)]()

The Gini Bank SDK provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this SDK into your application you can allow your users to easily take a picture of a document, review it and get analysis results from the Gini backend.

The Gini Bank SDK can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Bank SDK has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

## Documentation

Further documentation with installation, integration or customization guides can be found in our [website](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/).

## Example

We are providing the Bank and Health example apps for integrating payment functionality. The Bank app demonstrates how to integrate the Gini Bank SDK. The Health app initiates the payment flow.
To run the apps, clone the repo, open the project file and Resolve Package Versions in Xcode `File->Packages->Resolve Package Versions`.
To inject your API credentials into the Health and Bank example apps you need to fill in your credentials in [`HealthSDK/GiniHealthSDKExample/HealthSDKExample/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHeathSDKExample/HealthSDKExample/Credentials.plist) and [`BankSDK/GiniBankSDKExample/BankSDKExample/Credentials.plist`]((https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/BankSDKExample/Credentials.plist)), respectively.

## Requirements

- iOS 11+
- Xcode 12+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 11 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).

## Author

Gini GmbH, hello@gini.net

## License

The Gini Bank SDK for iOS is licensed under a Private License. See [the license](http://developer.gini.net/gini-mobile-ios/GiniBankSDK/license.html) for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
