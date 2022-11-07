# Contributing

## Prerequisites

### Install Swift

Install Swift through Xcode from the MacOS store, or if you don't want to install Xcode download Swift from [here](https://www.swift.org/download/).

## Build the SDK and Install Dependencies

Xcode will automatically download all of the necessary dependencies on build. If you're not using Xcode, the following command will download dependencies:

```shell
swift build
```

## Tests

The tests for this package exist on the [basistheory-ios-example](https://github.com/Basis-Theory/basistheory-ios-example) repo. It's recommended that you checkout the `basistheory-ios-example` repo and follow instructions for contributing there. `basistheory-ios-example` has this repo (`basistheory-ios`) as a git submodule, which means you're able to contribute to both repos from one directory. This is necessary for the `IntegrationTester` app in `basistheory-ios-example` to link to the `BasisTheoryElements` package here.
