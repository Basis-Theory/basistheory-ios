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

#import "GREYScreenshotter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @file GREYScreenshotter+Private.h
 * @brief Exposes GREYScreenshotter interfaces and methods that are otherwise private for testing
 * purposes.
 */

@interface GREYScreenshotter (Private)

/**
 * Provides a UIImage that is a screenshot, immediately or after the screen updates as specified.
 *
 * @param afterScreenUpdates A Boolean specifying if the screenshot is to be taken immediately or
 *                           after a screen update.
 * @param includeStatusBar   Include status bar in the screenshot.
 *
 * @return A UIImage containing a screenshot.
 */
+ (UIImage *)grey_takeScreenshotAfterScreenUpdates:(BOOL)afterScreenUpdates
                                     withStatusBar:(BOOL)includeStatusBar;

/**
 * @return A UIImage that is a screenshot of the specified bounds in the screen,
 *         immediately or after the screen updates as specified.
 *
 * @param afterScreenUpdates A BOOL specifying if the screenshot is to be taken immediately or
 *                           after a screen update.
 * @param screenRect         Frame in screen coordinate to capture in the screenshot.
 * @param includeStatusBar   Include status bar in the screenshot.
 */
+ (UIImage *)grey_takeScreenshotAfterScreenUpdates:(BOOL)afterScreenUpdates
                                      inScreenRect:(CGRect)screenRect
                                     withStatusBar:(BOOL)includeStatusBar;
@end

NS_ASSUME_NONNULL_END
