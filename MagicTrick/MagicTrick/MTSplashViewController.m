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

@import AVFoundation;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MTSplashViewController () <MTCardViewControllerDelegate>

@property (nonatomic, strong) UIView *splashContainerView;

@property (nonatomic, strong) MTAnimatingCardView *backgroundCardView;

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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x0F0124);
    
    self.splashContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.splashContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.splashContainerView];
    
    UIView *cardContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.splashContainerView addSubview:cardContainerView];
    
    self.backgroundCardView = [[MTAnimatingCardView alloc] initWithFrame:self.view.bounds];
    [self.backgroundCardView startAnimating];
    [cardContainerView addSubview:self.backgroundCardView];
    
    UIView *darkOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    darkOverlay.backgroundColor = [UIColor blackColor];
    darkOverlay.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
    darkOverlay.alpha = 0.3f;
    [cardContainerView addSubview:darkOverlay];
}

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
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.ghostImageView.center = CGPointMake(-CGRectGetWidth([UIScreen mainScreen].bounds)/2, self.ghostImageView.center.y);
                             self.splashContainerView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
                             self.splashContainerView.alpha = 0.0f;
                         } completion:^(BOOL finished) {

                         }];
        
        [UIView animateWithDuration:0.5f
                              delay:0.45f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.gameVC.view.alpha = 1.0f;
                             self.gameVC.view.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self.backgroundCardView stopAnimating];
                         }];
    }
}

#pragma mark - MTCardViewControllerDelegate methods

- (void)cardViewControllerDidDismiss:(ViewController *)cardViewController
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.gameVC.view.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
                         self.gameVC.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.gameVC willMoveToParentViewController:nil];
                         [self.gameVC.view removeFromSuperview];
                         [self.gameVC removeFromParentViewController];
                         self.gameVC = nil;
                     }];
    
    [UIView animateWithDuration:0.5f
                          delay:0.45f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.splashContainerView.transform = CGAffineTransformIdentity;
                         self.splashContainerView.alpha = 1.0f;
                         self.ghostImageView.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, self.ghostImageView.center.y);
                     } completion:^(BOOL finished) {
                         [self.backgroundCardView startAnimating];
                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.backgroundCardView stopAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.playImageView) {
        NSMutableArray *ghostImages = [[NSMutableArray alloc] init];
        
        for (int i = 0; i <= 59; i++) {
            [ghostImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"MAGIC_BOO_000%02d.png", i]]];
        }
        
        self.ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.ghostImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.ghostImageView.image = [ghostImages lastObject];
        self.ghostImageView.animationDuration = 2.0f;
        self.ghostImageView.animationImages = ghostImages;
        self.ghostImageView.animationRepeatCount = 1;
        [self.view addSubview:self.ghostImageView];
        [self.ghostImageView startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPlayButton];
        });
    }
}

- (void)showPlayButton
{
    NSMutableArray *playImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <= 30; i++) {
        [playImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Magic_000%02d.png", i]]];
    }
    
    self.playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Magic_00000.png"]];
    self.playImageView.animationImages = playImages;
    self.playImageView.animationDuration = 1.0f;
    self.playImageView.animationRepeatCount = 0;
    self.playImageView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    self.playImageView.alpha = 0.0f;
    self.playImageView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    self.playImageView.userInteractionEnabled = YES;
    [self.splashContainerView insertSubview:self.playImageView atIndex:100];
    
    [self.playImageView startAnimating];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play:)];
    [self.playImageView addGestureRecognizer:self.tapGesture];
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.playImageView.alpha = 1.0f;
                         self.playImageView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0f
                                               delay:0.0f
                                             options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                                          animations:^{
                                              self.playImageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);

                                             } completion:^(BOOL finished) {
                                                 
                                             }];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
