# Contributing

## Prerequisites

### Install Swift

Install Swift through Xcode from the MacOS store, or if you don't want to install Xcode download Swift from [here](https://www.swift.org/download/).

## Build the SDK and Install Dependencies

Xcode will automatically download all of the necessary dependencies on build. If you're not using Xcode, the following command will download dependencies:

```shell
swift build
```

## Running Locally

The `IntegrationTester` project is a small sample project that shows examples of integrating `BasisTheoryElements` modules. By following the instructions below, you're able to run all tests and examples:

1. Ensure `IntegrationTester` scheme is set
2. Pick an iOS simulator to run
3. Copy the contents `Env.plist.example` to a `Env.plist` file in the same directory and replace all necessary secrets. All API keys should be keys for dev. The `privateBtApiKey` should have read permissions with a reveal transform, and the `btApiKey` should be a public key with create permissions
4. Run the app! 🎉
