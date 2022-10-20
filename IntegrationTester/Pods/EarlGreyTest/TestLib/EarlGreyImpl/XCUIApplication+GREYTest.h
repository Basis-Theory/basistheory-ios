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

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class for extending XCUIApplication for EarlGrey in order to inject launch arguments required
 * for starting eDO sessions for performing RMI calls.
 */
@interface XCUIApplication (GREYTest)

/**
 * The testing application name showing on the launcher screen, or @c nil if the application has
 * not been launched.
 */
@property(class, readonly, nullable) NSString *greyTestRigName;

@end

NS_ASSUME_NONNULL_END
