//
// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "XCTestCase+GREYSystemAlertHandler.h"

#include <objc/runtime.h>

#import "GREYThrowDefines.h"
#import "GREYTestApplicationDistantObject.h"
#import "GREYErrorConstants.h"
#import "GREYAppleInternals.h"
#import "GREYAssertionDefines.h"
#import "GREYCondition.h"

/**
 * Text denoting part of the Camera System Alert.
 */
static NSString *const kSystemAlertLabelCamera = @"Camera";
/**
 * Text denoting part of the Photos System Alert.
 */
static NSString *const kSystemAlertLabelPhotos = @"Photos";
/**
 * Text denoting part of the Microphone System Alert.
 * TODO: Add functional tests for this. // NOLINT
 */
static NSString *const kSystemAlertLabelMicrophone = @"Microphone";
/**
 * Text denoting part of the Reminders System Alert.
 */
static NSString *const kSystemAlertLabelReminders = @"Reminders";
/**
 * Text denoting part of the Calendar System Alert.
 */
static NSString *const kSystemAlertLabelCalendar = @"Calendar";
/**
 * Text denoting part of the Notifications (APNS) System Alert.
 */
static NSString *const kSystemAlertLabelNotifications = @"Notifications";
/**
 * Text denoting part of the Motion Activity System Alert.
 */
static NSString *const kSystemAlertLabelMotionActivity = @"Motion & Fitness Activity";
/**
 * Text denoting part of the Contacts System Alert.
 */
static NSString *const kSystemAlertLabelContacts = @"Contacts";
/**
 * Timeout for system alerts to be present using the same check as that used by EarlGrey's app
 * component.
 */
CFTimeInterval const kSystemAlertEarlGreyVisibilityTimeout = 5;

CFTimeInterval const kSystemAlertVisibilityTimeout = 10;

#if TARGET_OS_IOS
/**
 * @return The Springboard's XCUIApplication.
 */
static XCUIApplication *GREYSpringboardApplication() {
  static XCUIApplication *gSpringBoardApplication;
  static dispatch_once_t token = 0;
  dispatch_once(&token, ^{
    gSpringBoardApplication =
        [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  });
  return gSpringBoardApplication;
}

/**
 * @return UIApplication under test by making an eDO call to the app-side.
 */
static UIApplication *GetApplicationUnderTest() {
  // TODO(b/148556743): Create a global instance for AUT in EarlGrey so we don't make an eDO call
  // each time.
  return [GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication];
}
#endif  // TARGET_OS_IOS

@implementation XCTestCase (GREYSystemAlertHandler)

#if TARGET_OS_IOS
- (NSString *)grey_systemAlertTextWithError:(NSError **)error {
  XCUIElement *topMostAlert = [self grey_topMostAlertWithError:error];
  if (!topMostAlert) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertNotPresent
                               userInfo:nil];
    }
    return nil;
  } else {
    return [topMostAlert label];
  }
}

- (GREYSystemAlertType)grey_systemAlertType {
  XCUIElement *topMostAlert = [self grey_topMostAlertWithError:nil];
  GREYAssertNotNil(topMostAlert, @"Alert does not exist");
  NSString *alertValue = [topMostAlert label];
  // There are two descriptions for the background alert, because it has two versions. It can be
  // the case that the location alert is not accepted, which means that a third value with a
  // "Use Once" option will be shown. If the location alert has already been shown, then the
  // denial alert button is not shown.
  if ([alertValue rangeOfString:kSystemAlertLabelCamera].location != NSNotFound) {
    return GREYSystemAlertTypeCamera;
  } else if ([alertValue rangeOfString:kSystemAlertLabelPhotos].location != NSNotFound) {
    return GREYSystemAlertTypePhotos;
  } else if ([alertValue rangeOfString:kSystemAlertLabelMicrophone].location != NSNotFound) {
    return GREYSystemAlertTypeMicrophone;
  } else if ([alertValue rangeOfString:kSystemAlertLabelCalendar].location != NSNotFound) {
    return GREYSystemAlertTypeCalendar;
  } else if ([alertValue rangeOfString:kSystemAlertLabelReminders].location != NSNotFound) {
    return GREYSystemAlertTypeReminder;
  } else if ([alertValue rangeOfString:kSystemAlertLabelNotifications].location != NSNotFound) {
    return GREYSystemAlertTypeNotifications;
  } else if ([alertValue rangeOfString:kSystemAlertLabelMotionActivity].location != NSNotFound) {
    return GREYSystemAlertTypeMotionActivity;
  } else if ([alertValue rangeOfString:kSystemAlertLabelContacts].location != NSNotFound) {
    return GREYSystemAlertTypeContacts;
  } else if ([self locationAlertStrings:GetAvailableLocationAlertStrings()
                 containSubstringOfLocationLabel:alertValue]) {
    return GREYSystemAlertTypeLocation;
  } else if ([self locationAlertStrings:GetAvailableBackgroundLocationAlertStrings()
                 containSubstringOfLocationLabel:alertValue]) {
    return GREYSystemAlertTypeBackgroundLocation;
  } else {
    GREYThrow(@"Invalid System Alert. Please add support for this value. Label is: %@", alertValue);
    return GREYSystemAlertTypeUnknown;
  }
}

- (BOOL)grey_acceptSystemDialogWithError:(NSError **)error {
  XCUIElement *alertInHierarchy = [self grey_topMostAlertWithError:error];
  if (!alertInHierarchy) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertAcceptButtonNotFound
                               userInfo:nil];
    }
    return NO;
  }
  NSString *alertText = [alertInHierarchy valueForKey:@"label"];

  XCUIElement *acceptButton = [[alertInHierarchy buttons] elementBoundByIndex:1];
  if (![acceptButton exists]) {
    NSLog(@"Accept button is not hittable\n%@", [GREYSpringboardApplication() debugDescription]);
    return NO;
  }

  BOOL dismissed = NO;
  @try {
    // Retry logic can solve the failure in slow animations mode.
    [acceptButton tap];
  } @catch (NSException *exception) {
    [self handleBrokeniOS12IssueIfNecessary:exception error:error];
    return NO;
  }
  dismissed = [self grey_ensureAlertDismissalOfAlertWithText:alertText error:error];
  [self grey_waitForAlertVisibility:NO withTimeout:kSystemAlertEarlGreyVisibilityTimeout];
  if (dismissed) {
    NSLog(@"EarlGrey accepted System Alert successfully.");
  }
  return dismissed;
}

- (BOOL)grey_denySystemDialogWithError:(NSError **)error {
  XCUIElement *alertInHierarchy = [self grey_topMostAlertWithError:error];
  if (!alertInHierarchy) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertDenialButtonNotFound
                               userInfo:nil];
    }
    return NO;
  }

  NSString *alertText = [alertInHierarchy valueForKey:@"label"];
  XCUIElement *denyButton;
  // In case of alerts such a Background Alert where a third "Always While Using This App" option
  // exists, hit the second button for denial.
  if ([[[alertInHierarchy buttons] elementBoundByIndex:2] exists]) {
    denyButton = [[alertInHierarchy buttons] elementBoundByIndex:2];
  } else if ([self grey_systemAlertType] == GREYSystemAlertTypeBackgroundLocation) {
    GREYThrow(@"Dismissing a Background Location System Alert once Location Alert is accepted.");
  } else {
    denyButton = [[alertInHierarchy buttons] firstMatch];
  }
  if (![denyButton exists]) {
    NSLog(@"Deny button is not hittable\n%@", [GREYSpringboardApplication() debugDescription]);
    return NO;
  }

  BOOL dismissed = NO;
  // Retry logic can solve the failure in slow animations mode.
  @try {
    [denyButton tap];
  } @catch (NSException *exception) {
    [self handleBrokeniOS12IssueIfNecessary:exception error:error];
    return NO;
  }
  dismissed = [self grey_ensureAlertDismissalOfAlertWithText:alertText error:error];
  [self grey_waitForAlertVisibility:NO withTimeout:kSystemAlertEarlGreyVisibilityTimeout];
  if (dismissed) {
    NSLog(@"EarlGrey successfully denied System Alert.");
  }
  return dismissed;
}

- (BOOL)grey_tapSystemDialogButtonWithText:(NSString *)text error:(NSError **)error {
  XCUIElement *firstAlertPresent = [self grey_topMostAlertWithError:error];
  if (![firstAlertPresent.buttons[text] exists]) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertCustomButtonNotFound
                               userInfo:nil];
    }
    return NO;
  }
  NSString *alertText = [firstAlertPresent valueForKey:@"label"];
  XCUIElement *button = firstAlertPresent.buttons[text];
  if (![button exists]) {
    NSLog(@"System Alert button is not hittable\n%@",
          [GREYSpringboardApplication() debugDescription]);
    return NO;
  }

  BOOL dismissed = NO;
  // Retry logic can solve the failure in slow animations mode.
  @try {
    [button tap];
  } @catch (NSException *exception) {
    [self handleBrokeniOS12IssueIfNecessary:exception error:error];
    return NO;
  }
  dismissed = [self grey_ensureAlertDismissalOfAlertWithText:alertText error:error];
  [self grey_waitForAlertVisibility:NO withTimeout:kSystemAlertEarlGreyVisibilityTimeout];
  if (dismissed) {
    NSLog(@"EarlGrey successfully accepted System Alert.");
  }
  return dismissed;
}

- (BOOL)grey_typeSystemAlertText:(NSString *)textToType
              forPlaceholderText:(NSString *)placeholderText
                           error:(NSError **)error {
  GREYThrowOnNilParameterWithMessage(textToType, @"textToType cannot be nil.");
  GREYThrowOnNilParameterWithMessage(placeholderText, @"placeholderText cannot be nil.");
  GREYThrowOnNilParameterWithMessage(placeholderText.length, @"placeholderText cannot be empty.");
  XCUIElement *firstAlertPresent = [self grey_topMostAlertWithError:error];
  XCUIElement *elementToType = nil;
  if (firstAlertPresent) {
    if ([firstAlertPresent.textFields[placeholderText] exists]) {
      elementToType = firstAlertPresent.textFields[placeholderText];
      [firstAlertPresent.textFields[placeholderText] tap];
      [firstAlertPresent.textFields[placeholderText] typeText:textToType];
    } else if ([firstAlertPresent.secureTextFields[placeholderText] exists]) {
      elementToType = firstAlertPresent.secureTextFields[placeholderText];
      [firstAlertPresent.secureTextFields[placeholderText] tap];
      [firstAlertPresent.secureTextFields[placeholderText] typeText:textToType];
    } else if ([firstAlertPresent.searchFields[placeholderText] exists]) {
      elementToType = firstAlertPresent.searchFields[placeholderText];
      [firstAlertPresent.secureTextFields[placeholderText] tap];
      [firstAlertPresent.secureTextFields[placeholderText] typeText:textToType];
    }
  }

  if (![elementToType exists]) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertTextNotTypedCorrectly
                               userInfo:nil];
    }
    return NO;
  }
  NSLog(@"EarlGrey successfully typed System Alert text: %@ in field with placeholder: %@.",
        textToType, placeholderText);
  return YES;
}

#pragma mark - Wait for alert

- (BOOL)grey_waitForAlertVisibility:(BOOL)visible withTimeout:(CFTimeInterval)seconds {
  GREYThrowOnFailedConditionWithMessage(seconds >= 0, @"timeout must be >= 0.");
  UIApplication *appUnderTest = GetApplicationUnderTest();
  BOOL (^alertShown)(void) = ^BOOL(void) {
    return [self springboardShowingAnAlertForApplication:appUnderTest];
  };
  BOOL (^alertNotShown)(void) = ^BOOL(void) {
    return ![self springboardShowingAnAlertForApplication:appUnderTest];
  };
  GREYCondition *condition =
      [GREYCondition conditionWithName:@"WaitForAlert"
                                 block:(visible ? alertShown : alertNotShown)];
  return [condition waitWithTimeout:seconds];
}

#pragma mark - Private

/**
 * Captures the internal OS error for the XCTest runtime exception for tapping on a system alert
 * with Xcode 13 and iOS 12.4 or less.  Reported as FB9858932. We attempt to take the cryptic
 * NSArray exception and turn it into something a little more actionable.
 *
 * @param exception The caught exception, which is raised if no @c error is passed in.
 * @param[out] error The wrapped error for the exception.
 */
- (void)handleBrokeniOS12IssueIfNecessary:(NSException *)exception error:(NSError **)error {
  NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
  if (osVersion.majorVersion <= 12 && [exception.name isEqualToString:NSInvalidArgumentException] &&
      [exception.reason
          containsString:@"__NSArrayM insertObject:atIndex:]: object cannot be nil"]) {
    NSString *description =
        @"iOS 12 has a bug with XCTest tapping on system alerts on Xcode 13+ (FB9858932). "
        @"Move tests to iOS 13+ if you are blocked. "
        @"https://openradar.appspot.com/radar?id=5520542106910720";
    if (error) {
      NSString *callStack = [exception.callStackSymbols.description copy];
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertOSError
                               userInfo:@{
                                 NSLocalizedDescriptionKey : description,
                                 NSLocalizedFailureReasonErrorKey : callStack
                               }];
    } else {
      [NSException raise:NSInternalInconsistencyException format:@"%@", description];
    }
  } else {
    [exception raise];
  }
}

/**
 * @return A BOOL denoting if the application under test is reporting a system alert being present.
 */
- (BOOL)springboardShowingAnAlertForApplication:(UIApplication *)application {
  // Before iOS 13, calling [[UIApplication sharedApplication] _isSpringBoardShowingAnAlert] from
  // any process returned the correct value. However, in iOS 13, you may only call
  // [[UIApplication sharedApplication] _isSpringBoardShowingAnAlert] from the application that
  // invoked it. If it's called in a different process (i.e. test runner), it always returns NO.
  return [application _isSpringBoardShowingAnAlert];
}

/**
 * @return The topmost alert view's XCUIElement, if present. @c nil otherwise.
 *
 * @param[out] error An NSError that will be populated if the alert is not visible.
 */
- (XCUIElement *)grey_topMostAlertWithError:(NSError **)error {
  XCUIApplication *springboardApp = GREYSpringboardApplication();
  XCUIElement *alert = [[springboardApp descendantsMatchingType:XCUIElementTypeAlert] firstMatch];
  if (![alert waitForExistenceWithTimeout:kSystemAlertVisibilityTimeout]) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertNotPresent
                               userInfo:nil];
    }
    return nil;
  }
  return alert;
}

/**
 * Ensures that the alert has been dismissed by checking the XCUITest Element Hierarchy for an
 * alert with the same label text.
 *
 * @param alertText  The text of the alert that was just dismissed.
 * @param[out] error An NSError that will be populated in case there is any issue.
 */
- (BOOL)grey_ensureAlertDismissalOfAlertWithText:(NSString *)alertText error:(NSError **)error {
  BOOL (^alertDismissedBlock)(void) = ^BOOL(void) {
    XCUIApplication *springboardApp = GREYSpringboardApplication();
    XCUIElementQuery *anyAlertPresentQuery =
        [springboardApp descendantsMatchingType:XCUIElementTypeAlert];
    NSString *label = nil;
    if ([anyAlertPresentQuery count]) {
      for (NSUInteger index = 0; index < [anyAlertPresentQuery count]; index++) {
        XCUIElement *anyAlertPresent = [anyAlertPresentQuery elementBoundByIndex:index];
        label = anyAlertPresent ? [anyAlertPresent valueForKey:@"label"] : @"";
        if ([label isEqualToString:alertText]) {
          return NO;
        }
      }
    }
    return YES;
  };

  GREYCondition *alertDismissed = [GREYCondition conditionWithName:@"Alert Dismissed"
                                                             block:alertDismissedBlock];
  if (![alertDismissed waitWithTimeout:kSystemAlertVisibilityTimeout pollInterval:0.5]) {
    if (error) {
      *error = [NSError errorWithDomain:kGREYSystemAlertDismissalErrorDomain
                                   code:GREYSystemAlertNotDismissed
                               userInfo:nil];
    }
    return NO;
  }
  return YES;
}

/**
 * Traverses @c substrings and checks if any of the traversing strings is a substring of @c label.
 */
- (BOOL)locationAlertStrings:(NSArray<NSString *> *)substrings
    containSubstringOfLocationLabel:(NSString *)label {
  for (NSString *substring in substrings) {
    if ([label rangeOfString:substring].location != NSNotFound) {
      return YES;
    }
  }
  return NO;
}

/**
 * @return An array of substrings that are available when location is requested for "When In Use".
 *         Displayed label is different across iOS versions.
 */
static NSArray<NSString *> *GetAvailableLocationAlertStrings() {
  if (iOS14_OR_ABOVE()) {
    return @[ @"use your location?" ];
  } else if (iOS13_OR_ABOVE()) {
    return @[ @"access your location?" ];
  } else if (iOS11_OR_ABOVE()) {
    return @[ @"location while you are using the app" ];
  } else {
    // iOS 11
    return @[ @"location while you use the app" ];
  }
}

/**
 * @return An array of substrings that are available when location is requested for "Always".
 *         Displayed label is different across iOS versions.
 */
static NSArray<NSString *> *GetAvailableBackgroundLocationAlertStrings() {
  if (iOS14_OR_ABOVE()) {
    return @[ @"use your location?" ];
  } else if (iOS13_OR_ABOVE()) {
    return @[ @"access your location?" ];
  } else if (iOS11_OR_ABOVE()) {
    // Second substring is shown when user requests for "Always" after "When In Use" location
    // request was authorized.
    return @[ @"access your location?", @"location even when you are not using the app?" ];
  } else {
    // iOS 11
    return @[ @"access your location?" ];
  }
}

#endif  // TARGET_OS_IOS

@end
