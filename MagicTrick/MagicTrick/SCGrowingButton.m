//
//  SCGrowingButton.m
//  Snapchat
//
//  Created by Will Wu on 2/11/14.
//  Copyright (c) 2014 Snapchat, Inc. All rights reserved.
//

#import "SCGrowingButton.h"

const CGFloat kSCGrowingButtonAnimationDuration   = 0.3f;
const CGFloat kSCGrowingButtonDefaultMaximumScale = 1.4f;
const CGFloat kSCGrowingButtonDefaultMinimumScale = 0.95f;

@interface SCGrowingButton ()

@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) BOOL pressed;
@property (nonatomic, weak) id target;

@end

@implementation SCGrowingButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.recognizesGesturesSimultaneously = NO;
        
        self.minimumScale = kSCGrowingButtonDefaultMinimumScale;
        self.maximumScale = kSCGrowingButtonDefaultMaximumScale;
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];

        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
        self.longPressGesture.minimumPressDuration = 0.0f;
        self.longPressGesture.delegate = self;
        [self addGestureRecognizer:self.longPressGesture];
        
        self.enabled = YES;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    // Update the UIImageView accordingly
    self.imageView.image = image;
    
    [self setNeedsLayout];
}

- (CGPoint)imageCenter
{
    // Return the center of the image in the coordinates of self
    CGFloat x = self.imageInset.width + self.image.size.width/2;
    CGFloat y = self.imageInset.height + self.image.size.height/2;    
    return CGPointMake(x, y);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(self.imageInset.width, self.imageInset.height, self.image.size.width, self.image.size.height);
}

- (void)press:(UILongPressGestureRecognizer*)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    CGRect bounds = gestureRecognizer.view.bounds;
    CGFloat originX = -bounds.size.width;
    CGFloat originY = -bounds.size.height;
    CGFloat width = bounds.size.width * 3;
    CGFloat height = bounds.size.height * 3;
    CGRect hitbox = CGRectMake(originX, originY, width, height);
    
    BOOL pressed = CGRectContainsPoint(hitbox, point);

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.pressed = YES;
        return;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.pressed != pressed) {
            self.pressed = pressed;
        }
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.pressed && [self.target respondsToSelector:self.action]) {
            if (self.isEnabled) {
                IMP imp = [self.target methodForSelector:self.action];
                void (*func)(id, SEL) = (void *)imp;
                func(self.target, self.action);
            }
        }
    }
    
    // Whether state is ended or canceled, reset the pressed state
    if (pressed || self.pressed) {
        self.pressed = NO;
    }
}

- (void)setPressed:(BOOL)pressed
{
    _pressed = pressed;
    
    if (pressed) {
        [self grow];
    } else {
        [self shrink];
    }
}

- (void)grow
{
    [self cancelExistingTransformAnimationsIfNeeded];
    [UIView animateWithDuration:kSCGrowingButtonAnimationDuration/2
                                delay:0.0f
               usingSpringWithDamping:1.0f
                initialSpringVelocity:0.1f
                              options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                           animations:^{
                               CGFloat radians = atan2f(self.transform.b, self.transform.a);
                               self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.maximumScale*(1.1), self.maximumScale*(1.1)));
                               
                               if (self.extraAnimationView) {
                                   CGFloat radians = atan2f(self.extraAnimationView.transform.b, self.extraAnimationView.transform.a);
                                   self.extraAnimationView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.maximumScale*(1.1), self.maximumScale*(1.1)));
                               }
                           } completion:^(BOOL finished) {
                               if (finished) {
                                   [UIView animateWithDuration:kSCGrowingButtonAnimationDuration/2
                                                               delay:0.0f
                                              usingSpringWithDamping:1.0f
                                               initialSpringVelocity:0.1f
                                                             options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                                                          animations:^{
                                                              CGFloat radians = atan2f(self.transform.b, self.transform.a);
                                                              self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.maximumScale, self.maximumScale));
                                                              
                                                              if (self.extraAnimationView) {
                                                                  CGFloat radians = atan2f(self.extraAnimationView.transform.b, self.extraAnimationView.transform.a);
                                                                  self.extraAnimationView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.maximumScale, self.maximumScale));
                                                              }
                                                          } completion:nil];
                               }
                           }];
}

- (void)shrink
{
    [self cancelExistingTransformAnimationsIfNeeded];
    [UIView animateWithDuration:kSCGrowingButtonAnimationDuration/2
                                delay:0.0f
               usingSpringWithDamping:1.0f
                initialSpringVelocity:0.1f
                              options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                           animations:^{
                               CGFloat radians = atan2f(self.transform.b, self.transform.a);
                               self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.minimumScale, self.minimumScale));
                               
                               if (self.extraAnimationView) {
                                   CGFloat radians = atan2f(self.extraAnimationView.transform.b, self.extraAnimationView.transform.a);
                                   self.extraAnimationView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformMakeScale(self.minimumScale, self.minimumScale));
                               }
                           } completion:^(BOOL finished) {
                               if (finished) {
                                   [UIView animateWithDuration:kSCGrowingButtonAnimationDuration/2
                                                               delay:0.0f
                                              usingSpringWithDamping:1.0f
                                               initialSpringVelocity:0.1f
                                                             options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                                                          animations:^{
                                                              CGFloat radians = atan2f(self.transform.b, self.transform.a);
                                                              self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformIdentity);
                                                              
                                                              if (self.extraAnimationView) {
                                                                  CGFloat radians = atan2f(self.extraAnimationView.transform.b, self.extraAnimationView.transform.a);
                                                                  self.extraAnimationView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(radians), CGAffineTransformIdentity);
                                                              }
                                                          } completion:nil];
                               }
                           }];
}

- (void)animate
{
    [self grow];
    
    double delayInSeconds = 0.075f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shrink];
    });
}

- (void)addTarget:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return self.recognizesGesturesSimultaneously;
}

// On iOS 8, -[UIView animateWithDuration:...] has changed its behavior and now all animations are additive by default.
// This breaks the current implementation of SCGrowingButton. To work around, we explicitly remove existing transfrom
// animations before adding new ones, which mimics the old iOS behaviors.
- (void)cancelExistingTransformAnimationsIfNeeded
{
    return;
}

@end
