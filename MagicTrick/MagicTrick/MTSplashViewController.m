//
//  MTSplashViewController.m
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTSplashViewController.h"
#import "MTAnimatingCardView.h"
#import "ViewController.h"
#import "MTSoundManager.h"

@import AVFoundation;

#define UIColorFromRGB(rgbValue)                                                                                       \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
                    alpha:1.0]

@interface MTSplashViewController () <MTCardViewControllerDelegate>

@property (nonatomic, strong) UIView *splashContainerView;

@property (nonatomic, strong) MTAnimatingCardView *backgroundCardView;

@property (nonatomic, strong) NSArray *ghostAnimationImages;

@property (nonatomic, strong) NSArray *idleGhostAnimationImages;

@property (nonatomic, strong) NSArray *playButtonAnimationImages;

@property (nonatomic, strong) UIImageView *ghostImageView;

@property (nonatomic, strong) UIImageView *playImageView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) ViewController *gameVC;

@end

@implementation MTSplashViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x0F0124);

    self.splashContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.splashContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.splashContainerView];

    self.backgroundCardView = [[MTAnimatingCardView alloc] initWithFrame:self.view.bounds];
    self.backgroundCardView.dimmed = YES;
    [self.backgroundCardView startAnimating];
    [self.splashContainerView addSubview:self.backgroundCardView];
}

// Animates a transition into the card view where you play the game
- (void)play:(UITapGestureRecognizer *)gesture
{
    if (!self.gameVC) {
        self.gameVC = [[ViewController alloc] init];
        self.gameVC.delegate = self;
        self.gameVC.view.alpha = 0.0f;
        self.gameVC.view.transform = CGAffineTransformMakeScale(10.0f, 10.0f);

        [self.gameVC willMoveToParentViewController:self];
        [self.view addSubview:self.gameVC.view];
        [self addChildViewController:self.gameVC];

        [[MTSoundManager sharedInstance] fadeOutSplashSounds];

        [UIView animateWithDuration:0.5f
            delay:0.0f
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.ghostImageView.center =
                    CGPointMake(-CGRectGetWidth([UIScreen mainScreen].bounds) / 2, self.ghostImageView.center.y);
                self.splashContainerView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
                self.splashContainerView.alpha = 0.0f;
            }
            completion:^(BOOL finished){

            }];

        [UIView animateWithDuration:0.5f
            delay:0.45f
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                self.gameVC.view.alpha = 1.0f;
                self.gameVC.view.transform = CGAffineTransformIdentity;
            }
            completion:^(BOOL finished){
            }];
    }
}

#pragma mark - MTCardViewControllerDelegate methods

// Animates a transition back to the splash screen
- (void)cardViewControllerDidDismiss:(ViewController *)cardViewController
{
    [UIView animateWithDuration:0.5f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            self.gameVC.view.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
            self.gameVC.view.alpha = 0.0f;
        }
        completion:^(BOOL finished) {
            [self.gameVC willMoveToParentViewController:nil];
            [self.gameVC.view removeFromSuperview];
            [self.gameVC removeFromParentViewController];
            self.gameVC = nil;

            [[MTSoundManager sharedInstance] fadeInSplashSounds];
        }];

    [UIView animateWithDuration:0.5f
        delay:0.45f
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{

            self.splashContainerView.transform = CGAffineTransformIdentity;
            self.splashContainerView.alpha = 1.0f;
            self.ghostImageView.center =
                CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 2, self.ghostImageView.center.y);
        }
        completion:^(BOOL finished){
        }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateInitialGhostAndPlayButtonIfNecessary];
    [[MTSoundManager sharedInstance] startBackgroundMusic];
}

- (void)preloadAllAnimationImagesWithCompletion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!self.ghostAnimationImages) {
            self.ghostAnimationImages = [[NSArray alloc] init];

            NSMutableArray *animationImages = [[NSMutableArray alloc] init];

            for (int i = 0; i <= 59; i++) {
                NSString *imagePath =
                    [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"MAGIC_BOO_000%02d@2x", i]
                                                    ofType:@"png"];

                // Pre-render the image using CoreGraphics
                UIImage *frameImage = [UIImage imageWithContentsOfFile:imagePath];
                UIGraphicsBeginImageContextWithOptions(frameImage.size, NO, [UIScreen mainScreen].scale);
                [frameImage drawInRect:CGRectMake(0, 0, frameImage.size.width, frameImage.size.height)];
                UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                [animationImages addObject:renderedImage];
            }

            self.ghostAnimationImages = [animationImages copy];
        }

        if (!self.idleGhostAnimationImages) {
            self.idleGhostAnimationImages = [[NSArray alloc] init];

            NSMutableArray *animationImages = [[NSMutableArray alloc] init];

            for (int i = 59; i >= 20; i--) {
                [animationImages addObject:self.ghostAnimationImages[i]];
            }

            [animationImages addObjectsFromArray:[[animationImages reverseObjectEnumerator] allObjects]];

            self.idleGhostAnimationImages = [animationImages copy];
        }

        if (!self.playButtonAnimationImages) {
            self.playButtonAnimationImages = [[NSArray alloc] init];

            NSMutableArray *animationImages = [[NSMutableArray alloc] init];

            for (int i = 0; i <= 30; i++) {
                NSString *imagePath =
                    [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Magic_000%02d@2x", i]
                                                    ofType:@"png"];

                // Pre-render the image using CoreGraphics
                UIImage *frameImage = [UIImage imageWithContentsOfFile:imagePath];
                UIGraphicsBeginImageContextWithOptions(frameImage.size, NO, [UIScreen mainScreen].scale);
                [frameImage drawInRect:CGRectMake(0, 0, frameImage.size.width, frameImage.size.height)];
                UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                [animationImages addObject:renderedImage];
            }

            self.playButtonAnimationImages = [animationImages copy];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });

    });
}

- (void)animateInitialGhostAndPlayButtonIfNecessary
{
    [self preloadAllAnimationImagesWithCompletion:^{
        // If we haven't shown the ghost and play button yet, animate it into view
        if (!self.playImageView && !self.ghostImageView) {
            self.ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            self.ghostImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.ghostImageView.image = [self.ghostAnimationImages lastObject];
            self.ghostImageView.animationDuration = 2.0f;
            self.ghostImageView.animationImages = self.ghostAnimationImages;
            self.ghostImageView.animationRepeatCount = 1;
            [self.view addSubview:self.ghostImageView];

            [self.ghostImageView startAnimating];

            [[MTSoundManager sharedInstance] playSound:MTSoundGhostSlide fromSplashScreen:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0f / 30.0f * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [[MTSoundManager sharedInstance] playSound:MTSoundWandPop fromSplashScreen:YES];
                           });

            // 1.1 seconds after ghost starts animating, we want to pop in the play button
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0f / 30.0f * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [self showPlayButton];
                           });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(),
                           ^{
                               [self recursiveAnimateIdleGhost];
                           });
        }
    }];
}

- (void)recursiveAnimateIdleGhost
{
    self.ghostImageView.animationDuration = (CGFloat)self.idleGhostAnimationImages.count / 30.0f;
    self.ghostImageView.animationImages = self.idleGhostAnimationImages;
    [self.ghostImageView startAnimating];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((30.0f) / 30.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MTSoundManager sharedInstance] playSound:MTSoundWandTap fromSplashScreen:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((46.0f) / 30.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MTSoundManager sharedInstance] playSound:MTSoundWandTap fromSplashScreen:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self recursiveAnimateIdleGhost];
    });
}

- (void)showPlayButton
{
    self.playImageView = [[UIImageView alloc] initWithImage:[self.playButtonAnimationImages lastObject]];
    self.playImageView.animationImages = self.playButtonAnimationImages;
    self.playImageView.animationDuration = 1.0f;
    self.playImageView.animationRepeatCount = 0;
    self.playImageView.center =
        CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    self.playImageView.alpha = 0.0f;
    self.playImageView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    self.playImageView.userInteractionEnabled = YES;
    [self.splashContainerView insertSubview:self.playImageView atIndex:100];

    [self.playImageView startAnimating];

    [[MTSoundManager sharedInstance] startPixieDust];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play:)];
    [self.playImageView addGestureRecognizer:self.tapGesture];

    [UIView animateWithDuration:0.35f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.playImageView.alpha = 1.0f;
            self.playImageView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0f
                delay:0.0f
                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut |
                        UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                animations:^{
                    self.playImageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);

                }
                completion:^(BOOL finished){

                }];
        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
