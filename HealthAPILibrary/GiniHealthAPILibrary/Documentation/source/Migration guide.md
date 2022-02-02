Migrate from the Gini Pay API Library
======================================

We've migrated from CocoaPods to Swift Package Manager. Please, find more details in [Installation](https://developer.gini.net/gini-mobile-ios/GiniHealthAPILibrary/installation.html).

## Update classes

Replace `GiniApiLib` with `GiniHealthAPI`.

To initialize the library, you will need to use the snippet below:

```swift
    let giniHealthAPI = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```

## Public Key Pinning

 Your pinning configuration shoul have `health-api.gini.net` domain like in the example below:

```swift
    let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
            "health-api.gini.net": [
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
```
