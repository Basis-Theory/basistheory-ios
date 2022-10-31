#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GREYAction.h"
#import "GREYActionsShorthand.h"
#import "GREYElementInteraction.h"
#import "GREYInteraction.h"
#import "GREYInteractionDataSource.h"
#import "GREYHostBackgroundDistantObject+GREYApp.h"
#import "GREYIdlingResource.h"
#import "GREYAllOf.h"
#import "GREYAnyOf.h"
#import "GREYMatchers.h"
#import "GREYMatchersShorthand.h"
#import "GREYAppStateTracker.h"
#import "GREYAppStateTrackerObject.h"
#import "GREYSyncAPI.h"
#import "GREYUIThreadExecutor.h"
#import "GREYAssertion.h"
#import "GREYAssertionBlock.h"
#import "GREYAssertionDefinesPrivate.h"
#import "GREYAppState.h"
#import "GREYConfigKey.h"
#import "GREYConfiguration.h"
#import "GREYDistantObjectUtils.h"
#import "GREYHostApplicationDistantObject.h"
#import "GREYHostBackgroundDistantObject.h"
#import "GREYTestApplicationDistantObject.h"
#import "GREYError.h"
#import "GREYErrorConstants.h"
#import "GREYFailureHandler.h"
#import "GREYFrameworkException.h"
#import "GREYConstants.h"
#import "GREYDefines.h"
#import "GREYDiagnosable.h"
#import "GREYLogger.h"
#import "GREYBaseMatcher.h"
#import "GREYDescription.h"
#import "GREYElementMatcherBlock.h"
#import "GREYMatcher.h"
#import "XCTestCase+GREYSystemAlertHandler.h"
#import "GREYAssertionDefines.h"
#import "GREYWaitFunctions.h"
#import "GREYCondition.h"
#import "EarlGrey.h"
#import "GREYElementHierarchy.h"

FOUNDATION_EXPORT double EarlGreyTestVersionNumber;
FOUNDATION_EXPORT const unsigned char EarlGreyTestVersionString[];

