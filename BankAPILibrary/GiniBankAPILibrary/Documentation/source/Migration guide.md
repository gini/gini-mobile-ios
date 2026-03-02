Migrate from the Gini Pay API Library
======================================

We've migrated from CocoaPods to Swift Package Manager. Please, find more details in [Installation](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/installation.html).

Update classes

Replace `GiniApiLib` with `GiniBankAPI`.

To initialize the library, you will need to use the snippet below:

```swift
    let giniBankAPI = GiniBankAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```

## Public Key Pinning

 Your pinning configuration should have `pay-api.gini.net` domain like in the example below:

```swift
    let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
            "pay-api.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
        ]] as [String: Any]

    let giniBankAPI = GiniBankAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .default,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```

## New Feature: Custom Network Provider

Version 4.1.0 introduces support for custom HTTP clients via the `setCustomNetworkProvider(_:)` method. This is particularly useful for:

- Corporate proxy configurations
- Custom TLS/SSL requirements
- Advanced logging and monitoring

**No action required** - This is a new opt-in feature. Your existing code will continue to work without changes.

If you need custom networking, see the "Custom Network Provider" section in the Getting Started guide.

### Example Usage

```swift
let customHTTPClient = MyHTTPClient()
let networkProvider = MyNetworkProvider(client: customHTTPClient)

let giniBankAPI = GiniBankAPI
    .Builder(client: Client(id: "your-id",
                            secret: "your-secret",
                            domain: "your-domain"))
    .setCustomNetworkProvider(networkProvider)
    .build()
```
