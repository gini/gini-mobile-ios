Installation
=============================

Gini Bank API Library can either be installed by using Swift Package Manager or by manually dragging the required files to your project.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniBankAPILibrary` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/gini/bank-api-library-ios.git", .exact("3.9.0"))
]
```
//TODO: Check healthAPILibrary documentation for the pinning part
## Manually

If you prefer not to use a dependency management tool, you can integrate the Gini Bank API Library into your project manually.
To do so drop the [GiniBankAPILibrary](https://github.com/gini/gini-mobile-ios/tree/main/BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary) (classes and assets) folder into your project and add the files to your target.
