![Gini Health SDK for iOS](./GiniHealth_Logo.png?raw=true)

# Gini Health SDK for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)]()


The Gini Health SDK provides components for uploading, reviewing and analyzing photos of invoices and remittance slips.

By integrating this SDK into your application you can allow your users to easily upload a picture of a document, review it and get analysis results from the Gini backend, create a payment and send it to the prefferable payment provider.

## Documentation

Further documentation with installation, integration or customization guides can be found in our [website](https://developer.gini.net/gini-mobile-ios/GiniHealthSDK/index.html).

## Example apps

We are providing example app for Swift. This app demonstrates how to integrate the Gini Health SDK with the Component API of [Gini Capture SDK](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/index.html).

An example banking app is available in the [Gini Mobile iOS monorepo](https://github.com/gini/gini-mobile-ios/tree/main/BankSDK/GiniBankSDKExample) repository.
To check the redirection to the Banking app please run Bank example before the Health example. You can use the same Gini Health API client credentials in the example banking app as in your app, if not otherwise specified.
To inject your API credentials into the Health and Bank example apps you need to fill in your credentials in [Credentials.plist](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist) and [Credentials.plist](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/Credentials.plist), respectively.

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

The Gini Health SDK for iOS is licensed under a Private License. See [the license](http://developer.gini.net/gini-mobile-ios/GiniHealthSDK/license.html) for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
