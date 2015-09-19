//
//  MTAnimatingStarView.m
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTAnimatingStarView.h"

typedef NS_ENUM(NSUInteger, MTStarPlane) {
    MTStarPlaneFarBackground,
    MTStarPlaneBackground,
    MTStarPlaneMiddleGround,
    MTStarPlaneForeground
};

static CGFloat const MTStarFarBackgroundAnimationDuration = 40.0f;
static CGFloat const MTStarBackgroundAnimationDuration = 45.0f;
static CGFloat const MTStarMiddleGroundAnimationDuration = 55.0f;
static CGFloat const MTStarForegroundAnimationDuration = 80.0f;

@interface MTAnimatingStarView ()

@property (nonatomic, assign) BOOL animating;

@end

@implementation MTAnimatingStarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)startAnimating
{
    self.animating = YES;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    UIView *farBackgroundView = [self nextStarViewAtStarPlane:MTStarPlaneFarBackground];
    UIView *backgroundView = [self nextStarViewAtStarPlane:MTStarPlaneBackground];
    UIView *middleGroundView = [self nextStarViewAtStarPlane:MTStarPlaneMiddleGround];
    UIView *foregroundView = [self nextStarViewAtStarPlane:MTStarPlaneForeground];
    
    farBackgroundView.center = backgroundView.center = middleGroundView.center = foregroundView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);

    [self addSubview:farBackgroundView];
    [self addSubview:backgroundView];
    [self addSubview:middleGroundView];
    [self addSubview:foregroundView];
    
    [UIView animateWithDuration:MTStarFarBackgroundAnimationDuration/2
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^{
                         farBackgroundView.frame = CGRectMake(0, -CGRectGetHeight(screenRect), CGRectGetWidth(farBackgroundView.frame), CGRectGetHeight(farBackgroundView.frame));
                     } completion:^(BOOL finished) {
                         [farBackgroundView removeFromSuperview];
                         [self animateNextStarViewAtStarPlane:MTStarPlaneFarBackground];
                     }];
    
    [UIView animateWithDuration:MTStarBackgroundAnimationDuration/2
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^{
                         backgroundView.frame = CGRectMake(0, -CGRectGetHeight(screenRect), CGRectGetWidth(backgroundView.frame), CGRectGetHeight(backgroundView.frame));
                     } completion:^(BOOL finished) {
                         [backgroundView removeFromSuperview];
                         [self animateNextStarViewAtStarPlane:MTStarPlaneBackground];
                     }];

    [UIView animateWithDuration:MTStarMiddleGroundAnimationDuration/2
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^{
                         middleGroundView.frame = CGRectMake(0, -CGRectGetHeight(screenRect), CGRectGetWidth(middleGroundView.frame), CGRectGetHeight(middleGroundView.frame));
                     } completion:^(BOOL finished) {
                         [middleGroundView removeFromSuperview];
                         [self animateNextStarViewAtStarPlane:MTStarPlaneMiddleGround];
                     }];

    [UIView animateWithDuration:MTStarForegroundAnimationDuration/2
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^{
                         foregroundView.frame = CGRectMake(0, -CGRectGetHeight(screenRect), CGRectGetWidth(foregroundView.frame), CGRectGetHeight(foregroundView.frame));
                     } completion:^(BOOL finished) {
                         [foregroundView removeFromSuperview];
                         [self animateNextStarViewAtStarPlane:MTStarPlaneForeground];
                     }];
    
    [self animateNextStarViewAtStarPlane:MTStarPlaneFarBackground];
    [self animateNextStarViewAtStarPlane:MTStarPlaneBackground];
    [self animateNextStarViewAtStarPlane:MTStarPlaneMiddleGround];
    [self animateNextStarViewAtStarPlane:MTStarPlaneForeground];
}

- (void)stopAnimating
{
    self.animating = NO;
    
    for (UIView *subview in self.subviews) {
        [subview.layer removeAllAnimations];
        [subview removeFromSuperview];
    }
}

- (void)animateNextStarViewAtStarPlane:(MTStarPlane)starPlane
{
    if (self.animating) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UIView *starView = [self nextStarViewAtStarPlane:starPlane];
        
        CGFloat animationDuration;
        
        switch (starPlane) {
            case MTStarPlaneFarBackground:
            {
                animationDuration = MTStarFarBackgroundAnimationDuration;
                break;
            }
            case MTStarPlaneBackground:
            {
                animationDuration = MTStarBackgroundAnimationDuration;
                break;
            }
            case MTStarPlaneMiddleGround:
            {
                animationDuration = MTStarMiddleGroundAnimationDuration;
                break;
            }
            case MTStarPlaneForeground:
            {
                animationDuration = MTStarForegroundAnimationDuration;
                break;
            }
            default:
                break;
        }
        
        [self addSubview:starView];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                         animations:^{
                             starView.frame = CGRectMake(0, -CGRectGetHeight(screenRect), CGRectGetWidth(starView.frame), CGRectGetHeight(starView.frame));
                         } completion:^(BOOL finished) {
                             [starView removeFromSuperview];
                             [self animateNextStarViewAtStarPlane:starPlane];
                         }];
    }
    
}

#pragma mark - Utility methods

- (UIView *)nextStarViewAtStarPlane:(MTStarPlane)starPlane
{
    CGFloat starSize, starCount, starAlpha;
    
    switch (starPlane) {
        case MTStarPlaneFarBackground:
        {
            starSize = 1.0f;
            starCount = 200.0f;
            starAlpha = 0.3f;
            break;
        }
        case MTStarPlaneBackground:
        {
            starSize = 2.0f;
            starCount = 100.0f;
            starAlpha = 0.4f;
            break;
        }
        case MTStarPlaneMiddleGround:
        {
            starSize = 3.0f;
            starCount = 50.0f;
            starAlpha = 0.5f;
            break;
        }
        case MTStarPlaneForeground:
        {
            starSize = 4.0f;
            starCount = 25.0f;
            starAlpha = 0.7f;
            break;
        }
        default:
            break;
    }
    
    UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    starView.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < starCount; i++) {
        UIView *star = [[UIView alloc] initWithFrame:CGRectMake(0, 0, starSize, starSize)];
        star.backgroundColor = [UIColor whiteColor];
        star.center = [self randomStarPoint];
        star.alpha = starAlpha;
        star.layer.cornerRadius = starSize / 2.0f;
        [starView addSubview:star];
    }
    
    return starView;
}

- (CGPoint)randomStarPoint
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    return CGPointMake([self randomFloatBetweenMinimum:0.0f andMaximum:CGRectGetWidth(screenRect)], [self randomFloatBetweenMinimum:0.0f andMaximum:CGRectGetHeight(screenRect)]);
}

- (CGFloat)randomFloatBetweenMinimum:(CGFloat)minimum andMaximum:(CGFloat)maximum
{
    CGFloat diff = maximum - minimum;
    return (((CGFloat) rand() / RAND_MAX) * diff) + minimum;
}

@end
