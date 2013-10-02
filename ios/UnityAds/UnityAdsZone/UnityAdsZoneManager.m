//
//  UnityAdsZoneManager.m
//  UnityAds
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Unity Technologies. All rights reserved.
//

#import "UnityAdsZoneManager.h"
#import "UnityAdsIncentivizedZone.h"

@interface UnityAdsZoneManager ()

@property (nonatomic, strong) NSMutableDictionary * _zones;
@property (nonatomic, strong) UnityAdsZone * _currentZone;

@end

@implementation UnityAdsZoneManager

static UnityAdsZoneManager *sharedZoneManager = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedZoneManager == nil) {
      sharedZoneManager = [[UnityAdsZoneManager alloc] init];
    }
	}
	return sharedZoneManager;
}

- (id)init {
  self = [super init];
  if(self) {
    self._zones = [[NSMutableDictionary alloc] init];
    self._currentZone = nil;
  }
  return self;
}

- (int)addZones:(NSDictionary *)zones {
  __block int addedZones = 0;
  [zones enumerateKeysAndObjectsUsingBlock:^(id zoneId, id zone, BOOL *stop) {
    if([self._zones objectForKey:zoneId] == nil) {
      [self._zones setObject:zone forKey:zoneId];
      ++addedZones;
    }
  }];
  return addedZones;
}

- (void)clearZones {
  [self._zones removeAllObjects];
}

- (NSDictionary *)getZones {
  return self._zones;
}

- (UnityAdsZone *)getZone:(NSString *)zoneId {
  return [self._zones objectForKey:zoneId];
}

- (BOOL)removeZone:(NSString *)zoneId {
  if([self._zones objectForKey:zoneId] != nil) {
    [self._zones removeObjectForKey:zoneId];
    return true;
  }
  return false;
}

- (BOOL)setCurrentZone:(NSString *)zoneId {
  id zone = [self._zones objectForKey:zoneId];
  if(zone != nil) {
    self._currentZone = zone;
    return true;
  }
  return false;
}

- (UnityAdsZone *)getCurrentZone {
  return self._currentZone;
}

- (int)zoneCount {
  return self._zones.count;
}

@end
