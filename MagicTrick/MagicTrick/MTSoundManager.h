//
//  MTSoundManager.h
//  MagicTrick
//
//  Created by Will Wu on 9/19/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MTSound) { MTSoundCardFlip, MTSoundCardDeal, MTSoundWandPop, MTSoundBackgroundMusic };

@interface MTSoundManager : NSObject

+ (instancetype)sharedInstance;

- (void)playSound:(MTSound)sound;

- (void)startBackgroundMusic;

- (void)stopBackgroundMusic;

@end
