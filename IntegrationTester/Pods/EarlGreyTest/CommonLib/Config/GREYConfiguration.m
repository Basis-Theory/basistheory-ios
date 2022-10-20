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

#import "GREYConfiguration.h"

#import "GREYConfiguration+Private.h"

@implementation GREYConfiguration

- (instancetype)init {
  self = [super init];
  if (self) {
    _needsMerge = YES;
  }
  return self;
}

+ (instancetype)sharedConfiguration {
  static GREYConfiguration *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = GREYCreateConfiguration();
  });
  return instance;
}

- (NSMutableDictionary *)mergedConfiguration {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)setValue:(id)value forConfigKey:(NSString *)configKey {
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setDefaultValue:(id)value forConfigKey:(NSString *)configKey {
  [self doesNotRecognizeSelector:_cmd];
}

- (void)reset {
  [self doesNotRecognizeSelector:_cmd];
}

- (id)valueForConfigKey:(NSString *)configKey {
  id value = self.mergedConfiguration[configKey];
  if (!value) {
    [NSException raise:@"NSUnknownKeyException" format:@"Unknown configuration key: %@", configKey];
  }
  return value;
}

- (BOOL)boolValueForConfigKey:(NSString *)configKey {
  id value = [self valueForConfigKey:configKey];
  return [value boolValue];
}

- (NSInteger)integerValueForConfigKey:(NSString *)configKey {
  id value = [self valueForConfigKey:configKey];
  return [value integerValue];
}

- (NSUInteger)unsignedIntegerValueForConfigKey:(NSString *)configKey {
  id value = [self valueForConfigKey:configKey];
  return [value unsignedIntegerValue];
}

- (double)doubleValueForConfigKey:(NSString *)configKey {
  id value = [self valueForConfigKey:configKey];
  return [value doubleValue];
}

- (NSString *)stringValueForConfigKey:(NSString *)configKey {
  NSString *value = [self valueForConfigKey:configKey];
  return value;
}

- (NSArray *)arrayValueForConfigKey:(NSString *)configKey {
  NSArray *value = [self valueForConfigKey:configKey];
  return value;
}

@end
