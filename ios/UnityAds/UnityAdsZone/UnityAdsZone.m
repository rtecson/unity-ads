//
//  UnityAdsZone.m
//  UnityAds
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Unity Technologies. All rights reserved.
//

#import "UnityAdsZone.h"
#import "UnityAdsConstants.h"

@interface UnityAdsZone ()

@property (nonatomic, strong) NSMutableDictionary *_options;

@end

@implementation UnityAdsZone

- (id)initWithData:(NSDictionary *)options {
  self = [super init];
  if(self) {
    self._options = [NSMutableDictionary dictionaryWithDictionary:options];
  }
  return self;
}

- (NSString *)getZoneId {
  return [self._options valueForKey:kUnityAdsZoneIdKey];
}

- (BOOL)allowsOverride:(NSString *)option {
  id allowOverrides = [self._options objectForKey:kUnityAdsZoneAllowOverrides];
  return [allowOverrides indexOfObject:option] != NSNotFound;
}

- (void)mergeOptions:(NSDictionary *)options {
  [options enumerateKeysAndObjectsUsingBlock:^(id optionKey, id optionValue, BOOL *stop) {
    if([self allowsOverride:optionKey]) {
      [self._options setObject:optionValue forKey:optionKey];
    }
  }];
}

@end
