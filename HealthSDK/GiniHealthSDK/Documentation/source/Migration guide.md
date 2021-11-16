Migrate from the Gini Pay Business SDK
=======================================

We've migrated from CocoaPods to Swift Package Manager. Please, find more details in [Installation](https://developer.gini.net/gini-mobile-ios/GiniHealthSDK/installation.html).

Update classes

Replace `GiniApiLib` with `GiniHealthAPI`.
Replace `GiniPayBusiness` with `GiniHealth`.
Replace `GiniPayBusinessConfiguration` with `GiniHealthConfiguration`.
Replace `GiniPayBusinessDelegate` with `GiniHealthDelegate`.
Replace `GiniPayBusinessError` with `GiniHealthError`.

Localizable strings

Replace `ginipaybusiness.*` with `ginihealth.*`.

Migrate from Pay API Library to Health API Library
===================================================

See the Health API Library's [migration guide](https://developer.gini.net/gini-mobile-ios/GiniHealthAPILibrary/migration-guide.html).