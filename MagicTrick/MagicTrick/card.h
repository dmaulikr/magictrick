//
//  cardView.h
//  MagicTrick
//
//  Created by Lucy Guo on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface card : UIView

@property (nonatomic, strong) UIImageView *cardView;
@property (nonatomic) NSInteger *value;
@property (nonatomic) BOOL symmetrical;
@property (nonatomic) BOOL faceDown;

- (void)newCard;

@end

