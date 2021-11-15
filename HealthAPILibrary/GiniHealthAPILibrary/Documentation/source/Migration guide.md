Migrate from the Gini Pay API Library
======================================

We've migrated from CocoaPods to Swift Package Manager. Please, find more details in [Installation](https://developer.gini.net/gini-mobile-ios/GiniHealthAPILibrary/installation.html).

Update classes

Replace `GiniApiLib` with `GiniHealthAPI`.

To initialize the library, you will need to use the snippet below:

```swift
    let giniHealthAPI = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```