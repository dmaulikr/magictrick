//
//  SCGrowingButton.h
//  Snapchat
//
//  Created by Will Wu on 2/11/14.
//  Copyright (c) 2014 Snapchat, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCGrowingButton : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGSize imageInset;
@property (nonatomic, assign) CGFloat maximumScale;
@property (nonatomic, assign) CGFloat minimumScale;
@property (nonatomic, assign) BOOL recognizesGesturesSimultaneously;
@property (nonatomic, strong) UIView* extraAnimationView;
@property (nonatomic, getter=isEnabled, assign) BOOL enabled;

- (void)addTarget:(id)target action:(SEL)action;
- (void)press:(UILongPressGestureRecognizer*)gestureRecognizer;
- (CGPoint)imageCenter;
- (void)animate;

@end
