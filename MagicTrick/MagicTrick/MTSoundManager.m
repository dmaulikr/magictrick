//
//  MTSoundManager.m
//  MagicTrick
//
//  Created by Will Wu on 9/19/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTSoundManager.h"

@import AVFoundation;

@interface MTSoundManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableArray *audioPlayers;

@property (nonatomic, strong) AVAudioPlayer *backgroundMusicAudioPlayer;

@end

@implementation MTSoundManager

+ (instancetype)sharedInstance
{
    static MTSoundManager *soundManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundManager = [[self alloc] init];
    });
    return soundManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioPlayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)playSound:(MTSound)sound
{
    NSURL *soundUrl = [self urlForSound:sound];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    audioPlayer.delegate = self;
    [self.audioPlayers addObject:audioPlayer];
    [audioPlayer play];
}

- (void)startBackgroundMusic
{
    if (!self.backgroundMusicAudioPlayer) {
        self.backgroundMusicAudioPlayer =
            [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlForSound:MTSoundBackgroundMusic] error:nil];
        self.backgroundMusicAudioPlayer.numberOfLoops = -1;
    }

    [self.backgroundMusicAudioPlayer play];
}

- (void)stopBackgroundMusic
{
    [self.backgroundMusicAudioPlayer stop];
}

- (NSURL *)urlForSound:(MTSound)sound
{
    NSURL *soundUrl = nil;

    switch (sound) {
    case MTSoundBackgroundMusic: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"song_of_storms" ofType:@"mp3"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundCardFlip: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"card_flip" ofType:@"mp3"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundCardDeal: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"card_deal" ofType:@"m4a"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundWandPop: {
        break;
    }
    default:
        break;
    }

    return soundUrl;
}

#pragma mark - AVAudioPlayerDelegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.audioPlayers removeObject:player];
}

@end
