//
//  cardView.m
//  MagicTrick
//
//  Created by Lucy Guo on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "card.h"

@interface card ()

// Private interface goes here.

@end

@implementation card

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setupValue];
    return self;
}

- (void)setupValue {
    _faceDown = YES;
}



@end
