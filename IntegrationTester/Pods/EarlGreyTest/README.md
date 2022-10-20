[![Apache License](https://img.shields.io/badge/license-Apache%202-lightgrey.svg?style=flat)](https://github.com/google/EarlGrey/blob/earlgrey2/LICENSE)
![Build Status](https://app.bitrise.io/app/0b4975da22d56e16/status.svg?token=5TrWUStkI51GjdO7PgEueQ)

**Note:** EarlGrey 2.0 currently supports Xcode Projects and building from source for both white
and black box testing. CocoaPods support is present for black-box testing. Contributions are
welcome for CocoaPods white-box testing and other package managers.

To use, please clone the `earlgrey2` branch with its submodules:

```
// Clone EarlGrey 2.0
git clone -b earlgrey2 https://github.com/google/EarlGrey.git

// Download any dependencies
sh Scripts/download_deps.sh
```

# EarlGrey 2.0

EarlGrey 2.0 is a native iOS UI automation test framework that combines
[EarlGrey](https://github.com/google/EarlGrey) with [XCUITest](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html), Apple's official
UI Testing Framework.

EarlGrey 2.0 allows you to write clear, concise tests in Objective-C / Swift and
enables out of process interactions with XCUITest. It has the following
chief advantages:

* **Synchronization:** From run to run, EarlGrey 2.0 ensures that you will get the same result
  in your tests, by making sure that the application is idle. It does so by automatically
  tracking UI changes, network requests and various queues. EarlGrey 2.0 also allows
  you to manually implement custom timings.
* **White-box:** EarlGrey 2.0 allows you to query the application under test from your tests.
* **Native Development:** As with EarlGrey 1.0, you can use EarlGrey 2.0 natively with Xcode.
  You can run tests directly from Xcode or xcodebuild. Please note that EarlGrey 2.0 uses a UI
  Testing Target and not a Unit Testing Target like EarlGrey 1.0.

EarlGrey 1.0 is a white-box testing tool that allows you to interact with the application under test.
Since XCUITest is a black-box testing framework, this is not directly possible with EarlGrey 2.0.
To fix this, we use [eDistantObject
(eDO)](https://github.com/google/eDistantObject)
to allow these white-box interactions.

# Using EarlGrey 2.0

To integrate with EarlGrey 2.0 using Xcode Projects, please take a look at our
[Setup Guide](docs/setup.md). For CocoaPods, please look at the
[CocoaPods Setup Guide](docs/cocoapods-setup.md).

For a quick sample project, take a look at our
[FunctionalTests](Tests/Functional/FunctionalTests.xcodeproj)
project.

# Getting Help

You can use the same channels as with EarlGrey 1.0 for communicating with us. Please use the
`earlgrey-2` tag to differentiate the projects.

*   [Known Issues](https://github.com/google/EarlGrey/issues)
*   [Stack Overflow](http://stackoverflow.com/questions/tagged/earlgrey2)
*   [Slack](https://googleoss.slack.com/messages/earlgrey)
*   [Google Group](https://groups.google.com/g/earlgrey-discuss)

# Apple Privacy Description Labels & Analytics

EarlGrey is not intended to be shipped in user facing products so we are not supplying formal Apple
Privacy Description Label guidelines. That being said, this product does **not** collect or transmit
any analytics or personal data.

# Licensing

All project source code is licensed under the Apache 2.0 license. All image resources are licensed
under the Creative Commons Attribution 4.0 International (CC BY 4.0) license. The texts of both
licenses are included in the [LICENSE](https://github.com/google/EarlGrey/blob/earlgrey2/LICENSE)
file.


# EarlGrey 2.0 advantages over XCUITest

*   Automatic synchronization with Animations, Dispatch Queues, and Network Requests as enumerated [here](https://github.com/google/EarlGrey/blob/master/docs/features.md#synchronization).
*   In-built White-Box Testing Support with RMI.
*   Better Support for Flakiness Issues.
*   Better Control of tests. EarlGrey has a much larger set of matchers.
*   EarlGrey performs a pixel-by-pixel check for the visibility of an element.

# EarlGrey 2.0 advantages over EarlGrey 1.0

*   Out of Process Testing using XCUITest. So System Alerts, Inter-app
    interactions etc. are supported
*   Lesser throttling of the application under test's main thread.
*   Better support since accessibility is provided out of the box with XCUITest.

# Caveats

*   You cannot directly access the application under test as with EarlGrey 1.0.
    You need to use [eDistantObject (eDO)](https://github.com/google/eDistantObject)
    to do so.
*   XCUITest application launches can add a 6+ second delay. Please use
    [XCUIApplication
    launch](https://developer.apple.com/documentation/xctest/xcuiapplication/1500467-launch?language=objc)
    judiciously.
