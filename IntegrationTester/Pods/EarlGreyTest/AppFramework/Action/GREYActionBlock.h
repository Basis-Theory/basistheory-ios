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

#import "GREYBaseAction.h"

@protocol GREYMatcher;

/**
 * Block type for defining the action's 'perform' code.
 *
 * @param      element    The element on which the block is going to be performed.
 * @param[out] errorOrNil The error set on failure. The error returned can be @c nil, signifying
 *                        that the action succeeded.
 *
 * @return @c YES if the action performed succeeded, else @c NO.
 */
typedef BOOL (^GREYPerformBlock)(id element, __strong NSError **errorOrNil);

/**
 * A class for creating block based GREYAction.
 */
@interface GREYActionBlock : GREYBaseAction

/**
 * Creates a GREYAction that performs the action in the provided @c block subject to the
 * provided @c constraints.
 *
 * @param name  The name of the action.
 * @param block A block that contains the action to execute.
 *
 * @note GREYActions are not performed by default on the main thread. The threading
 *       behavior of the GREYAction has to be specified by the user.
 *
 * @return A GREYActionBlock instance with the given name and constraints.
 */
+ (instancetype)actionWithName:(NSString *)name performBlock:(GREYPerformBlock)block;

/**
 * Creates a GREYAction that performs the action in the provided @c block subject to the
 * provided @c constraints.
 *
 * @param name        The name of the action.
 * @param constraints Constraints that must be satisfied before the action is performed
 *                    This is optional and can be @c nil.
 * @param block       A block that contains the action to execute.
 *
 * @note GREYActions are not performed by default on the main thread. The threading
 *       behavior of the GREYAction has to be specified by the user.
 *
 * @return A GREYActionBlock instance with the given name and constraints.
 */
+ (instancetype)actionWithName:(NSString *)name
                   constraints:(id<GREYMatcher>)constraints
                  performBlock:(GREYPerformBlock)block;

/**
 * @remark init is not an available initializer. Use the other initializers.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @remark initWithName::constraints: is overridden from its superclass.
 */
- (instancetype)initWithName:(NSString *)name
                 constraints:(id<GREYMatcher>)constraints NS_UNAVAILABLE;

/**
 * Convenience Initializer.
 *
 * @param name                  The name of the action.
 * @param constraints           Constraints that must be satisfied before the action is performed
 *                              This is optional and can be @c nil.
 * @param block                 A block that contains the action to execute.
 *
 * @return A GREYActionBlock instance with the given name and constraints.
 */
- (instancetype)initWithName:(NSString *)name
                 constraints:(id<GREYMatcher>)constraints
                performBlock:(GREYPerformBlock)block;

/**
 * Designated Initializer.
 *
 * @param name                  The name of the action.
 * @param constraints           Constraints that must be satisfied before the action is performed
 *                              This is optional and can be @c nil.
 * @param shouldRunOnMainThread Whether or not if the action should run on the main thread or
 *                              background thread. Pass @c YES unless there's a reason not to. See
 *                              details in GREYAction.h.
 * @param block                 A block that contains the action to execute.
 *
 * @note GREYActions are not performed by default on the main thread. The threading behavior of the
 *       GREYAction has to be specified by the user.
 *
 * @return A GREYActionBlock instance with the given name and constraints.
 */
- (instancetype)initWithName:(NSString *)name
                 constraints:(id<GREYMatcher>)constraints
                onMainThread:(BOOL)shouldRunOnMainThread
                performBlock:(GREYPerformBlock)block NS_DESIGNATED_INITIALIZER;

@end
