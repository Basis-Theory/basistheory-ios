//
// Copyright 2016 Google Inc.
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

#import <Foundation/Foundation.h>

#import "GREYDefines.h"

/**
 * @file
 * @brief Miscellaneous functions that are used for EarlGrey synchronization.
 */

/**
 * Executes a block containing EarlGrey statements on the main thread and waits for it to
 * complete. @c block is retained until execution completes.
 *
 * @note  Can be called from any thread.
 * @param block Block that will be executed.
 */
GREY_EXPORT void grey_dispatch_sync_on_main_thread(void (^block)(void));

/**
 * A utility method to wait for a particular condition to be satisfied. If a condition is not
 * met, the current thread's run loop is drained once and the condition is checked again. This
 * activity is repeated until the timeout provided expires.
 *
 * @note  Always call this on the main thread.
 * @param checkConditionBlock Block that checks condition.
 * @param timeout             The timeout time to check the condition.
 *
 * @return @c YES if the condition specified in the condition block was satisfied before the
 *         timeout. @c NO otherwise.
 */
GREY_EXPORT BOOL grey_check_condition_until_timeout(BOOL (^checkConditionBlock)(void),
                                                    double timeout);
