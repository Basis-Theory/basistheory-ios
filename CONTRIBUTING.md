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

The `IntegrationTester` project is a small sample iOS app that shows examples of integrating `BasisTheoryElements` modules. By following the instructions below, you're able to run all tests and examples:

1. Ensure `IntegrationTester` scheme is set
2. Pick an iOS simulator to run
3. Copy the contents `Env.plist.example` to a `Env.plist` file in the same directory and replace all necessary secrets.

   1. All API keys should be keys for dev. The `privateBtApiKey` should have `token:read` permissions with a `reveal` transform, and the `btApiKey` should be a public key with `token:create` permissions
   2. `proxyKey` should have the `destination_url` set to `https://echo.basistheory.com/post` with `require_auth` set to `true`
   3. `proxyKeyNoAuth` should have the `destination_url` set to `https://echo.basistheory.com/get` with `require_auth` set to `false`

4. Run the app! 🎉

## Running tests

Unit tests are under `IntegrationTester/UnitTests` and acceptance tests are under `IntegrationTester/AcceptanceTests`.
