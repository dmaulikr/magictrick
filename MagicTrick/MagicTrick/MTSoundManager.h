//
//  MTSoundManager.h
//  MagicTrick
//
//  Created by Will Wu on 9/19/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSUInteger, MTSound) {
    MTSoundCardFlip,
    MTSoundCardDeal,
    MTSoundWandPop,
    MTSoundWandTap,
    MTSoundBackgroundMusic,
    MTSoundPixieDust,
    MTSoundGhostSlide
};

@interface MTSoundManager : NSObject

+ (instancetype)sharedInstance;

- (void)playSound:(MTSound)sound fromSplashScreen:(BOOL)fromSplashScreen;

- (void)startBackgroundMusic;

- (void)stopBackgroundMusic;

- (void)startPixieDust;

- (void)stopPixieDust;

- (void)fadeOutSplashSounds;

- (void)fadeInSplashSounds;

@end
