//
//  MTAnimatingCardView.h
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTAnimatingCardView : UIView

@property (nonatomic, assign) BOOL dimmed;

- (void)startAnimating;

- (void)stopAnimating;

@end
