//
//  UnityAdsVideo.m
//  UnityAds
//
//  Created by bluesun on 10/22/12.
//  Copyright (c) 2012 Unity Technologies. All rights reserved.
//

#import "UnityAdsVideo.h"
#import "../UnityAds.h"
#import "../UnityAdsCampaign/UnityAdsCampaign.h"

id timeObserver;
id analyticsTimeObserver;
VideoAnalyticsPosition videoPosition;
UnityAdsCampaign *selectedCampaign;

@implementation UnityAdsVideo

- (void)createPlayerLayer {
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)playSelectedVideo {
#if !(TARGET_IPHONE_SIMULATOR)
	__block UnityAdsVideo *blockSelf = self;
  timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
    [blockSelf _videoPositionChanged:time];
	}];
#endif
	
  videoPosition = kVideoAnalyticsPositionUnplayed;
	Float64 duration = [self _currentVideoDuration];
	NSMutableArray *analyticsTimeValues = [NSMutableArray array];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .25]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .5]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .75]];
  
#if !(TARGET_IPHONE_SIMULATOR)
  analyticsTimeObserver = [self addBoundaryTimeObserverForTimes:analyticsTimeValues queue:nil usingBlock:^{
		[blockSelf _logVideoAnalytics];
	}];
#endif
	
	[self play];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  
  [self.delegate videoPlaybackStarted];
	[self _logVideoAnalytics];
}

- (void)_videoPlaybackEnded:(NSNotification *)notification
{
	UALOG_DEBUG(@"");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

#if (TARGET_IPHONE_SIMULATOR)
  videoPosition = kVideoAnalyticsPositionThirdQuartile;
#endif
  
  [self _logVideoAnalytics];
	[self removeTimeObserver:timeObserver];
	timeObserver = nil;
	[self removeTimeObserver:analyticsTimeObserver];
	analyticsTimeObserver = nil;
  
  [self.delegate videoPlaybackEnded];
}

- (void)_videoPositionChanged:(CMTime)time {
  [self.delegate videoPositionChanged:time];
}

- (void)_logVideoAnalytics
{
	videoPosition++;
	[self.delegate videoAnalyticsPositionReached:videoPosition];
}

- (Float64)_currentVideoDuration
{
	CMTime durationTime = self.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration
{
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}


@end
