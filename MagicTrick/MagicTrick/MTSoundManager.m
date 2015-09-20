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

@property (nonatomic, strong) NSMutableArray *splashAudioPlayers;

@property (nonatomic, strong) AVAudioPlayer *backgroundMusicAudioPlayer;

@property (nonatomic, strong) AVAudioPlayer *pixieDustAudioPlayer;

@property (nonatomic, assign) BOOL fadingIn;

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
        self.splashAudioPlayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)playSound:(MTSound)sound fromSplashScreen:(BOOL)fromSplashScreen
{
    NSURL *soundUrl = [self urlForSound:sound];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    audioPlayer.delegate = self;
    [self.audioPlayers addObject:audioPlayer];

    if (fromSplashScreen) {
        AVAudioPlayer *otherPlayer = [self.splashAudioPlayers firstObject];
        if (otherPlayer) {
            audioPlayer.volume = otherPlayer.volume;
        }
        [self.splashAudioPlayers addObject:audioPlayer];
    }

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

- (void)startPixieDust
{
    if (!self.pixieDustAudioPlayer) {
        self.pixieDustAudioPlayer =
            [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlForSound:MTSoundPixieDust] error:nil];
        self.pixieDustAudioPlayer.numberOfLoops = -1;
        [self.splashAudioPlayers addObject:self.pixieDustAudioPlayer];
    }

    self.pixieDustAudioPlayer.volume = 0.0f;
    [self.pixieDustAudioPlayer play];
    [self fadeInSplashSounds];
}

- (void)stopPixieDust
{
    [self.pixieDustAudioPlayer stop];
}

- (void)fadeInSplashSounds
{
    self.fadingIn = YES;
    [self recursiveFadeInSplashSounds];
}

- (void)fadeOutSplashSounds
{
    self.fadingIn = NO;
    [self recursiveFadeOutSplashSounds];
}

- (void)recursiveFadeInSplashSounds
{
    if (self.fadingIn) {
        CGFloat fadeDuration = 0.5f;
        CGFloat fadeDelta = 0.1f;

        for (AVAudioPlayer *player in self.splashAudioPlayers) {
            if (player.volume < 1.0f) {
                CGFloat newVolume = MIN(1.0f, player.volume + fadeDelta);
                player.volume = newVolume;
            }
        }

        [self performSelector:@selector(recursiveFadeInSplashSounds)
                   withObject:nil
                   afterDelay:fadeDelta * fadeDuration];
    }
}

- (void)recursiveFadeOutSplashSounds
{
    if (!self.fadingIn) {
        CGFloat fadeDuration = 0.5f;
        CGFloat fadeDelta = 0.1f;

        for (AVAudioPlayer *player in self.splashAudioPlayers) {
            if (player.volume > 0.0f) {
                CGFloat newVolume = MAX(0, player.volume - fadeDelta);
                player.volume = newVolume;
            }
        }

        [self performSelector:@selector(recursiveFadeOutSplashSounds)
                   withObject:nil
                   afterDelay:fadeDelta * fadeDuration];
    }
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
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wand_pop" ofType:@"mp3"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundPixieDust: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"pixie_dust" ofType:@"m4a"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundWandTap: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wand_tap" ofType:@"mp3"];
        soundUrl = [NSURL fileURLWithPath:path];
        break;
    }
    case MTSoundGhostSlide: {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ghost_slide" ofType:@"mp3"];
        soundUrl = [NSURL fileURLWithPath:path];
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
    if ([self.audioPlayers containsObject:player]) {
        [self.audioPlayers removeObject:player];
    }

    if ([self.splashAudioPlayers containsObject:player]) {
        [self.splashAudioPlayers removeObject:player];
    }
}

@end
