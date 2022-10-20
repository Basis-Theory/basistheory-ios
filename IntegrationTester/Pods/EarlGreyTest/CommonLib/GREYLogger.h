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

/**
 * @file GREYLogger.h
 * @brief Macro for printing more logs for aiding in debugging.
 */

#import "GREYDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * NSUserDefaults key for checking if verbose logging is turned on. (i.e. logs with
 * GREYLogVerbose are printed.)
 */
GREY_EXTERN NSString* _Nonnull const kGREYAllowVerboseLogging;

/**
 * NSUserDefaults value for printing all verbose logs.
 */
GREY_EXTERN NSString* _Nonnull const kGREYVerboseLoggingKeyAll;

/**
 * NSUserDefaults value for printing interaction logs.
 */
GREY_EXTERN NSString* _Nonnull const kGREYVerboseLoggingKeyInteraction;

/**
 * NSUserDefaults value for printing app state logs.
 */
GREY_EXTERN NSString* _Nonnull const kGREYVerboseLoggingKeyAppState;

/**
 * NSUserDefaults value for printing send touch events logs.
 */
GREY_EXTERN NSString* _Nonnull const kGREYVerboseLoggingKeySendTouchEvent;

/**
 * Enum values for verbose logging.
 */
typedef NS_OPTIONS(NSInteger, GREYVerboseLogType) {
  /** Prints Interaction Verbose Logs.*/
  kGREYVerboseLogTypeInteraction = 1 << 0,
  /** Prints App State Tracker Verbose Logs.*/
  kGREYVerboseLogTypeAppState = 1 << 1,
  /** Prints Touch Injection Events Sent to UIApplication. */
  kGREYVerboseLogTypeSendTouchEvent = 1 << 2,
  /** Prints all logs Verbose Logs (Use sparingly and never in prod).*/
  kGREYVerboseLogTypeAll = kGREYVerboseLogTypeInteraction | kGREYVerboseLogTypeAppState |
                           kGREYVerboseLogTypeSendTouchEvent
};

/**
 * @return The Verbose logging type for a string value passed in.
 *
 * @param verboseLoggingString The NSString that is to be mapped to a verbose logging type.
 */
GREYVerboseLogType GREYVerboseLogTypeFromString(NSString* verboseLoggingString);

/**
 * @return @c YES if verbose logging is enabled.
 */
BOOL GREYVerboseLoggingEnabled(void);  // NOLINT

/**
 * @return @c YES if verbose logging is enabled for the provided @c level.
 *
 * @param level The logging level to be checked for being enabled.
 */
BOOL GREYVerboseLoggingEnabledForLevel(GREYVerboseLogType level);

/**
 * Prints a log statement if any of the following keys are present in NSUserDefaults at the start
 * of the launch of the application process.
 *
 * There are multiple ways to turn on verbose logging:
 *
 * 1. Pass a test environment flag for a test run. On bazel, you can pass in:
 *    @code
 *      --test_env=eg_verbose_logs=interaction|app_state|send_touch_event|all
 *    @endcode
 *
 * 2. Pass in a @c GREYLogVerboseType key with a non-zero string value in -[XCUIApplication
 *    launchArguments].
 *
 *    e.g. Prints all interaction related logs.
 *    @code
 *      NSMutableArray<NSString *> *launchArguments = [[NSMutableArray alloc] init];
 *      [launchArguments addObject:[@"-" stringByAppendingString:kGREYAllowVerboseLogging]];
 *      NSString *loggingType = [NSString stringWithFormat:@"%zd", kGREYVerboseLogTypeInteraction];
 *      [launchArguments addObject:loggingType];
 *      self.application.launchArguments = launchArguments;
 *      [self.application launch];
 *    @endcode
 *
 * 3. In the App side, you can pass it in the scheme's Environment Variables or set it in the test
 *    side for logging over a particular part of the test.
 *
 *    @code
 *      - (void)testFoo {
 *        NSUserDefaults *userDefaults =
 *            [GREY_REMOTE_CLASS_IN_APP(NSUserDefaults) standardUserDefaults];
 *        [userDefaults setInteger:kGREYVerboseLogTypeInteraction forKey:kGREYAllowVerboseLogging];
 *        ...
 *        // Verbose logs added
 *        ...
 *      }
 * @endcode
 *
 * @remark Once you set this, as with any NSUserDefaults, you need to
 *         explicitly turn it off or delete and re-install the app under test.
 *
 * @param format The string format to be printed.
 * @param ...    The parameters to be added to the string format.
 */
void GREYLogVerbose(NSString* format, ...);

NS_ASSUME_NONNULL_END
