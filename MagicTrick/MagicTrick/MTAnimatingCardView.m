//
//  MTAnimatingCardView.m
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTAnimatingCardView.h"
#import "MTCardImageManager.h"

@interface MTAnimatingCardView ()

@property (nonatomic, strong) NSArray *allCards;

@property (nonatomic, strong) NSTimer *fireTimer;

@property (nonatomic, strong) NSNumber *cardWidth;

@property (nonatomic, strong) NSNumber *cardHeight;

@end

@implementation MTAnimatingCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.allCards = [[MTCardImageManager sharedInstance].allCards copy];
    }
    return self;
}

- (void)startAnimating
{
    if (self.fireTimer) {
        [self.fireTimer invalidate];
    }
    
    self.fireTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(animateNextCard:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopAnimating
{
    if (self.fireTimer) {
        [self.fireTimer invalidate];
    }
}

#pragma mark - Utility methods

- (void)animateNextCard:(NSTimer *)timer
{
    NSMutableArray *quadrants = [@[@(0), @(1), @(2), @(3)] mutableCopy];
    
    NSNumber *startQuadrant = quadrants[arc4random() % quadrants.count];
    [quadrants removeObject:startQuadrant];
    
    NSNumber *endQuadrant = quadrants[arc4random() % quadrants.count];
    
    CGPoint startCenter = [self randomPointInQuadrant:[startQuadrant unsignedIntegerValue]];
    CGPoint endCenter = [self randomPointInQuadrant:[endQuadrant unsignedIntegerValue]];
    
    UIImageView *cardView = [self generateNewCardView];
    
    CGAffineTransform scale = [self randomScaledTransform];
    CGFloat randomDuration = [self randomFloatBetweenMinimum:20.0f andMaximum:30.0f];
    
    cardView.transform = scale;
    cardView.center = startCenter;
    
    [self addSubview:cardView];
    
    CGFloat randomNumberOfRotations = [self randomFloatBetweenMinimum:-0.3f andMaximum:0.3f];
    [UIView animateWithDuration:randomDuration
                     animations:^{
                         [self addSpinAnimationToView:cardView duration:randomDuration withNumberOfRotations:randomNumberOfRotations];
                         cardView.center = endCenter;
                     } completion:^(BOOL finished) {
                         [cardView.layer removeAllAnimations];
                         [cardView removeFromSuperview];
                     }];
}

- (UIImageView *)generateNewCardView
{
    NSArray *backProbabilityArray = @[@(YES),
                                      @(YES),
                                      @(NO),
                                      @(NO),
                                      @(NO),
                                      @(NO),
                                      @(NO),
                                      @(NO),
                                      @(NO),
                                      @(NO)];
    
    BOOL isFaceDown = [backProbabilityArray[arc4random() % backProbabilityArray.count] boolValue];
    UIImage *cardImage = nil;
    
    if (isFaceDown) {
        cardImage = [UIImage imageNamed:@"back.png"];
    }
    
    else {
        NSUInteger randomIndex = arc4random() % self.allCards.count;
        MTCard *randomCard = self.allCards[randomIndex];
        cardImage = randomCard.cardImage;
    }


    UIImageView *cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self.cardWidth floatValue], [self.cardHeight floatValue])];
    cardView.image = cardImage;
    cardView.clipsToBounds = YES;
    cardView.layer.cornerRadius = 5.0f;
    
    return cardView;
}

- (void)addSpinAnimationToView:(UIView*)view duration:(CGFloat)duration withNumberOfRotations:(CGFloat)rotations
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (CGAffineTransform)randomRotatedTransform
{
    CGFloat minimumAngle = -10*(M_PI);
    CGFloat maximumAngle = 10*(M_PI);
    CGFloat randomAngle = [self randomFloatBetweenMinimum:minimumAngle andMaximum:maximumAngle];
    CGAffineTransform randomRotation = CGAffineTransformMakeRotation(randomAngle);
    return randomRotation;
}

- (CGAffineTransform)randomScaledTransform
{
    CGFloat minimumScale = 0.2f;
    CGFloat maximumScale = 1.0f;
    CGFloat randomScale = [self randomFloatBetweenMinimum:minimumScale andMaximum:maximumScale];
    CGAffineTransform randomTransform = CGAffineTransformMakeScale(randomScale, randomScale);
    return randomTransform;
}

- (CGPoint)randomPointInQuadrant:(NSUInteger)quadrant
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    
    // somewhere far off screen
    CGPoint point;
    
    switch (quadrant) {
        case 0:
        {
            CGFloat minX = 0;
            CGFloat maxX = screenWidth;
            CGFloat y = -[self.cardHeight floatValue];
            point = CGPointMake([self randomFloatBetweenMinimum:minX andMaximum:maxX], y);
            break;
        }
        case 1:
        {
            CGFloat x = screenWidth + [self.cardWidth floatValue];
            CGFloat minY = 0;
            CGFloat maxY = screenHeight;
            point = CGPointMake(x, [self randomFloatBetweenMinimum:minY andMaximum:maxY]);
            break;
        }
        case 2:
        {
            CGFloat minX = 0;
            CGFloat maxX = screenWidth;
            CGFloat y = screenHeight + [self.cardHeight floatValue];
            point = CGPointMake([self randomFloatBetweenMinimum:minX andMaximum:maxX], y);
            break;
        }
        case 3:
        {
            CGFloat x = -(screenWidth + [self.cardWidth floatValue]);
            CGFloat minY = 0;
            CGFloat maxY = screenHeight;
            point = CGPointMake(x, [self randomFloatBetweenMinimum:minY andMaximum:maxY]);
            break;
        }
        default: {
            point = CGPointMake(-10000, -10000);
            break;
        }
    }
    return point;
}

- (CGFloat)randomFloatBetweenMinimum:(CGFloat)minimum andMaximum:(CGFloat)maximum
{
    CGFloat diff = maximum - minimum;
    return (((CGFloat) rand() / RAND_MAX) * diff) + minimum;
}

#pragma mark - Lazy methods

- (NSNumber *)cardWidth
{
    if (!_cardWidth) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        _cardWidth = @(CGRectGetWidth(screenRect) / 6);
    }
    return _cardWidth;
}

- (NSNumber *)cardHeight
{
    if (!_cardHeight) {
        CGFloat cardWidth = 375.0f;
        CGFloat cardHeight = 525.0f;
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat scaledCardWidth = CGRectGetWidth(screenRect) / 6;
        _cardHeight = @((scaledCardWidth / cardWidth) * cardHeight);
    }
    return _cardHeight;
}

@end
