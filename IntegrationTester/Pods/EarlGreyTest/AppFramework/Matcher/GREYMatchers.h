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

#import <Foundation/Foundation.h>

#import "GREYConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class GREYLayoutConstraint;

@protocol GREYMatcher;

/**
 * EarlGrey matchers for UI elements.
 */
@interface GREYMatchers : NSObject

/**
 * Matcher for application's key window.
 *
 * @return A matcher for the application's key window.
 */
+ (id<GREYMatcher>)matcherForKeyWindow;

/**
 * Matcher for UI element with the provided accessibility @c label.
 *
 * @param label The accessibility label to be matched.
 *
 * @return A matcher for the accessibility label of an accessible element.
 */
+ (id<GREYMatcher>)matcherForAccessibilityLabel:(NSString *)label;

/**
 * Matcher for UI element with the provided accessibility ID @c accessibilityID.
 *
 * @param accessibilityID The accessibility ID to be matched.
 *
 * @return A matcher for the accessibility ID of an accessible element.
 */
+ (id<GREYMatcher>)matcherForAccessibilityID:(NSString *)accessibilityID;

/**
 * Matcher for UI element with the provided accessibility @c value.
 *
 * @param value The accessibility value to be matched.
 *
 * @return A matcher for the accessibility value of an accessible element.
 */
+ (id<GREYMatcher>)matcherForAccessibilityValue:(NSString *)value;

/**
 * Matcher for UI element with the provided accessibility @c traits.
 *
 * @param traits The accessibility traits to be matched.
 *
 * @return A matcher for the accessibility traits of an accessible element.
 *
 */
+ (id<GREYMatcher>)matcherForAccessibilityTraits:(UIAccessibilityTraits)traits;

/**
 * Matcher for UI element with the provided accessiblity @c hint.
 *
 * @param hint The accessibility hint to be matched.
 *
 * @return A matcher for the accessibility hint of an accessible element.
 */
+ (id<GREYMatcher>)matcherForAccessibilityHint:(NSString *)hint;

/**
 * Matcher for UI element with accessiblity focus.
 *
 * @return A matcher for the accessibility focus of an accessible element.
 */
+ (id<GREYMatcher>)matcherForAccessibilityElementIsFocused;

/**
 * Matcher for UI elements of type UILabel, UITextField or UITextView displaying the provided
 * @c inputText. For matching with a UIButton's title text, please use
 * GREYMatchers::matcherForButtonTitle: instead.
 *
 * @param text The text to be matched in the UI elements.
 *
 * @return A matcher to check for any UI elements with a text field containing the given text.
 */
+ (id<GREYMatcher>)matcherForText:(NSString *)text;

/**
 * Matcher for element that is the first responder.
 *
 * @return A matcher that verifies if a UI element is the first responder.
 */
+ (id<GREYMatcher>)matcherForFirstResponder;

/**
 * Matcher to check if system alert view is shown.
 *
 * @return A matcher to check if a system alert view is being shown.
 */
+ (id<GREYMatcher>)matcherForSystemAlertViewShown;

/**
 * Matcher for UI element whose percent visible area (of its accessibility frame) exceeds the
 * given @c percent.
 *
 * @note This is an expensive check (can take around 250ms for a simple 100 x 100 pt view). Do not
 *       use it in your selectElementWithMatcher statement for matching an element but use it to
 *       assert on a matched element's state.
 *
 * @param percent The percent visible area that the UI element being matched has to be visible.
 *                Allowed values for @c percent are [0,1] inclusive.
 *
 * @return A matcher that checks if a UI element has a visible area at least equal
 *         to a minimum value.
 */
+ (id<GREYMatcher>)matcherForMinimumVisiblePercent:(CGFloat)percent;

/**
 * Matcher for UI element that is sufficiently visible to the user. EarlGrey considers elements
 * that are more than @c kElementSufficientlyVisiblePercentage (75 %) visible areawise to be
 * sufficiently visible.
 *
 * @note This is an expensive check (can take around 250ms for a simple 100 x 100 pt view). Do not
 *       use it in your selectElementWithMatcher statement for matching an element but use it to
 *       assert on a matched element's state. Also, an element is considered not visible if it is
 *       obscured by another view with an @c alpha greater than or equal to 0.95.
 *
 * @return A matcher initialized with a visibility percentage that confirms an element is
 *         sufficiently visible.
 */
+ (id<GREYMatcher>)matcherForSufficientlyVisible;

/**
 * Matcher for UI element that is not visible to the user at all i.e. it has a zero visible area.
 *
 * @note This is an expensive check (can take around 250ms for a simple 100 x 100 pt view). Do not
 *       use it in your selectElementWithMatcher statement for matching an element but use it to
 *       assert on a matched element's state.
 *
 * @return A matcher for verifying if an element is not visible.
 */
+ (id<GREYMatcher>)matcherForNotVisible;

/**
 * Matcher for UI element that matches EarlGrey's criteria for user interaction. Currently it must
 * satisfy at least the following criteria:
 * 1) At least a few pixels of the element are visible to the user.
 * 2) The element's accessibility activation point OR the center of the element's visible area
 *    is completely visible.
 *
 * @return A matcher that checks if a UI element is interactable.
 */
+ (id<GREYMatcher>)matcherForInteractable;

/**
 * Matcher to check if a UI element is accessible.
 *
 * @return A matcher that checks if a UI element is accessible.
 */
+ (id<GREYMatcher>)matcherForAccessibilityElement;

/**
 * Matcher for elements that are instances of the provided @c klass or any class that inherits from
 * it.
 *
 * @note Passing a null class will always fail. This is only added in case of dynamically obtained
 *       Class variables using NSClassFromString which may be null.
 *
 * @param klass A class.
 *
 * @return A matcher that checks if the given element's class is the provided @c klass or any of
 *         its derived classes.
 */
+ (id<GREYMatcher>)matcherForKindOfClass:(nullable Class)klass;

/**
 * Matcher for elements that are instances of the class that's returned by
 * @c NSClassFromString(className).
 *
 * @param className The name of the class the matched element has to be an instance of, as
 *                  returned by NSClassFromString(className).
 *
 * @return A matcher that checks if the given element's class has the provided @c className or
 *         any of its derived classes.
 *
 * @throws NSInternalInconsistencyException if @c className does not return a valid class.
 */
+ (id<GREYMatcher>)matcherForKindOfClassName:(NSString *)className;

/**
 * Matcher for matching UIProgressView's values. Use greaterThan, greaterThanOrEqualTo,
 * lessThan etc to create @c comparisonMatcher. For example, to match the UIProgressView
 * elements that have progress value greater than 50.2, use
 * @code [GREYMatchers matcherForProgress:grey_greaterThan(@(50.2))] @endcode. In case if an
 * unimplemented matcher is required, please implement it similar to @c grey_closeTo.
 *
 * @param comparisonMatcher The matcher with the value to check the progress against.
 *
 * @return A matcher for checking a UIProgessView's value.
 */
+ (id<GREYMatcher>)matcherForProgress:(id<GREYMatcher>)comparisonMatcher;

/**
 * Matcher for UI element that respond to the provided @c sel.
 *
 * @param sel The selector to be responded to.
 *
 * @return A matcher to check if a UI element's class responds to a particular selector.
 */
+ (id<GREYMatcher>)matcherForRespondsToSelector:(SEL)sel;

/**
 * Matcher for UI element that conform to the provided @c protocol.
 *
 * @param protocol The protocol that the UI element must conform to.
 *
 * @return A matcher to check if a UI element's class confirms to a particular protocol.
 */
+ (id<GREYMatcher>)matcherForConformsToProtocol:(Protocol *)protocol;

/**
 * Matcher that matches UI element based on the presence of an ancestor in its hierarchy.
 * The given matcher is used to match decendants.
 *
 * @param ancestorMatcher The ancestor UI element whose descendants are to be matched.
 *
 * @return A matcher to check if a UI element is the descendant of another.
 */
+ (id<GREYMatcher>)matcherForAncestor:(id<GREYMatcher>)ancestorMatcher;

/**
 * Matcher that matches any UI element with a descendant matching the given matcher.
 *
 * @param descendantMatcher A matcher being checked to be a descendant
 *                          of the UI element being checked.
 *
 * @return A matcher to check if a the specified element is in a descendant of another UI element.
 */
+ (id<GREYMatcher>)matcherForDescendant:(id<GREYMatcher>)descendantMatcher;

/**
 * Matcher that matches UIButton that has title label as @c text.
 *
 * @param title The title to be checked on the UIButtons being matched.
 *
 * @return A matcher to confirm UIButton titles.
 */
+ (id<GREYMatcher>)matcherForButtonTitle:(NSString *)title;

/**
 * Matcher that matches UIScrollView that has contentOffset as @c offset.
 *
 * @param offset The content offset to be checked on the UIScrollView being
 *               matched.
 *
 * @return A matcher to confirm UIScrollView content offset.
 */
+ (id<GREYMatcher>)matcherForScrollViewContentOffset:(CGPoint)offset;

/**
 * Matcher that matches UIStepper with value as @c value.
 *
 * @param value A value that the UIStepper should be checked for.
 *
 * @return A matcher for checking UIStepper values.
 */
+ (id<GREYMatcher>)matcherForStepperValue:(double)value;

/**
 * Matcher that matches a UISlider's value.
 *
 * @param valueMatcher A matcher for the UISlider's value. You must provide a valid
 *                     @c valueMatcher for the floating point value comparison. The
 *                     @c valueMatcher should be of the type @c closeTo, @c greaterThan,
 *                     @c lessThan, @c lessThanOrEqualTo, @c greaterThanOrEqualTo. The
 *                     value matchers should account for any loss in precision for the given
 *                     floating point value. If you are using @c grey_closeTo, use delta diff as
 *                     @c kGREYAcceptableFloatDifference. In case if an unimplemented matcher
 *                     is required, please implement it similar to @c grey_closeTo.
 *
 * @return A matcher for checking a UISlider's value.
 */
+ (id<GREYMatcher>)matcherForSliderValueMatcher:(id<GREYMatcher>)valueMatcher;

/**
 * Matcher that matches UIPickerView that has a column set to @c value.
 *
 * @param column The column of the UIPickerView to be matched.
 * @param value  The value that should be set in the column of the UIPickerView.
 *
 * @return A matcher to check the value in a particular column of a UIPickerView.
 */
+ (id<GREYMatcher>)matcherForPickerColumn:(NSInteger)column setToValue:(NSString *)value;

/**
 * Matcher that matches UIDatePicker that is set to @c value.
 *
 * @param value The date value that should be present in the UIDatePicker
 *
 * @return A matcher for a date in a UIDatePicker.
 */
+ (id<GREYMatcher>)matcherForDatePickerValue:(NSDate *)value;

/**
 * Matcher that verifies whether an element, that is a UIControl, is enabled.
 *
 * @return A matcher for checking whether a UI element is an enabled UIControl.
 */
+ (id<GREYMatcher>)matcherForEnabledElement;

/**
 * Matcher that verifies whether an element, that is a UIControl, is selected.
 *
 * @return A matcher for checking whether a UI element is a selected UIControl.
 */
+ (id<GREYMatcher>)matcherForSelectedElement;

/**
 * Matcher that verifies whether a view has its userInteractionEnabled property set to @c YES.
 *
 * @return A matcher for checking whether a view' userInteractionEnabled property is set to @c YES.
 */
+ (id<GREYMatcher>)matcherForUserInteractionEnabled;

/**
 * Matcher that verifies that the selected element satisfies the given constraints to the
 * reference element.
 * Usage:
 * @code
 * GREYLayoutConstraint *constraint1 = [GREYLayoutConstraint layoutConstraintWithAttribute ... ];
 * GREYLayoutConstraint *constraint2 = [GREYLayoutConstraint layoutConstraintForDirection ... ];
 * id<GREYMatcher> *matcher = [GREYMatcher matcherForLayoutConstraints:@[ constraint1, constraint2]
 *                                          toReferenceElementMatching:aReferenceElementMatcher];
 * [EarlGrey selectElementWithMatcher ...] assertWithMatcher:matcher];
 * @endcode
 *
 * @param constraints             The constraints to be matched.
 * @param referenceElementMatcher The reference element with the correct constraints.
 *
 * @remark Constraints are often represented using floating point numbers. Floating point
 *         arithmetic can often induce errors based on the way the numbers are represented in
 *         hardware; hence, floating point comparisons use a margin value
 *         @c kGREYAcceptableFloatDifference that is used for adding accuracy to such arithmetic.
 *
 * @return A matcher to verify the GREYLayoutConstraints on a UI element.
 */
+ (id<GREYMatcher>)matcherForLayoutConstraints:(NSArray<GREYLayoutConstraint *> *)constraints
                    toReferenceElementMatching:(id<GREYMatcher>)referenceElementMatcher;

/**
 * Matcher primarily for asserting that the element is @c nil or not found.
 *
 * @return A matcher to check if a specified element is @c nil or not found.
 */
+ (id<GREYMatcher>)matcherForNil;

/**
 * Matcher for asserting that the element exists in the UI hierarchy (i.e. not @c nil). If used as
 * an assertion, this will pass if no element was matched by the selection matcher.
 *
 * @return A matcher to check if a specified element is not @c nil.
 */
+ (id<GREYMatcher>)matcherForNotNil;

/**
 * Matcher for toggling the switch control.
 *
 * @param on The state of the switch control. The switch control is in ON state if @c on is @c YES
 *           or OFF state if @c on is NO.
 *
 * @return A matcher to check if a UISwitch is on or off.
 */
+ (id<GREYMatcher>)matcherForSwitchWithOnState:(BOOL)on;

/**
 * A Matcher for NSNumbers that matches when the examined number is within a specified @c delta
 * from the specified value.
 *
 * @param value The expected value of the number being matched.
 *
 * @param delta The delta within which matches are allowed
 *
 * @return A matcher that checks if a number is close to a specified @c value.
 */
+ (id<GREYMatcher>)matcherForCloseTo:(double)value delta:(double)delta;

/**
 * A Matcher that matches against any object, including @c nils.
 *
 * @return A matcher that matches any object.
 */
+ (id<GREYMatcher>)matcherForAnything;

/**
 * A Matcher that checks if a provided object is equal to the specified @c value. The equality is
 * determined by calling the @c isEqual: method of the object being examined. In case the @c
 * value is @c nil, then the object itself is checked to be @c nil.
 *
 * @param value  The value to be checked for equality. Please ensure that scalar types are
 *               passed in as boxed (object) values.
 *
 * @return A matcher that checks if an object is equal to the provided one.
 */
+ (id<GREYMatcher>)matcherForEqualTo:(id)value;

/**
 * A Matcher that checks if a provided object is less than a specified @c value. The comparison
 * is made by calling the @c compare: method of the object being examined.
 *
 * @param value The value to be compared, which should return @c NSOrderedDescending. Please
 *              ensure that scalar values are passed in as boxed (object) values.
 *
 * @return A matcher that checks an object is lesser than another provided @c value.
 */
+ (id<GREYMatcher>)matcherForLessThan:(id)value;

/**
 * A Matcher that checks if a provided object is greater than a specified @c value. The comparison
 * is made by calling the @c compare: method of the object being examined.
 *
 * @param value The value to be compared, which should return @c NSOrderedAscending. Please
 *              ensure that scalar values are passed in as boxed (object) values.
 *
 * @return A matcher that checks an object is greater than another provided @c value.
 */
+ (id<GREYMatcher>)matcherForGreaterThan:(id)value;

/**
 * Matcher that matches a UIScrollView scrolled to content @c edge.
 *
 * @param edge The content edge UIScrollView should be scrolled to.
 *
 * @return A matcher that matches a UIScrollView scrolled to content @c edge.
 */
+ (id<GREYMatcher>)matcherForScrolledToContentEdge:(GREYContentEdge)edge;

/**
 * Matcher that matches a UITextField's content.
 *
 * @param value The text string contained inside the UITextField.
 *
 * @return A matcher that matches the value inside a UITextField.
 */
+ (id<GREYMatcher>)matcherForTextFieldValue:(NSString *)value;

/**
 * A matcher to check the negation of the result of @c matcher.
 *
 * @param matcher A matcher whose result will be negated.
 *
 * @return An matcher that negates the result of @c matcher.
 */
+ (id<GREYMatcher>)matcherForNegation:(id<GREYMatcher>)matcher;

/**
 * A matcher for a UIView element that has its hidden value equal to the passed-in BOOL.
 *
 * @param hidden The passed-in BOOL for checking if the element is hidden or not.
 **/
+ (id<GREYMatcher>)matcherForHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
