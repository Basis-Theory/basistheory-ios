# basistheory-ios

## Packages

`BasisTheoryElements` - A package containing simple, secure, developer-friendly inputs that empower consumers to collect sensitive data from their users directly to Basis Theory’s certified vault.

### Modules

`TextElementUITextField` - A simple wrapper for the native UIKit UITextField, this enables developers to take full advantage of existing native customization while also restricting their system access to the underlying data.

## Examples

The `IntegrationTester` app is an example of how to integrate modules from the `BasisTheoryElements` package.

## Installation

### Swift Package Manager

#### Via Xcode

Add through Xcode via _File -> Add Packages_. Search for "https://github.com/Basis-Theory/basistheory-ios" and click on "Copy Dependency".

#### Via Package.swift

Add the following line under `dependencies` to your `Package.swift`:

```swift
    .package(url: "https://github.com/Basis-Theory/basistheory-ios", from: "X.X.X"),
```

And add `BasisTheoryElements` as a dependency to your `target`:

```swift
    dependencies: [
        .product(name: "BasisTheoryElements", package: "basistheory-ios"),
        ...
    ],
```

### CocoaPods

Add the following line to your `Podfile` under your `target`:

```ruby
    pod 'BasisTheoryElements'
```
