//
//  MTCardImageManager.h
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "MTCard.h"

@interface MTCardImageManager : NSObject

+ (instancetype)sharedInstance;

- (MTCard *)cardWithSuit:(MTCardSuit)cardSuit andValue:(NSInteger)cardValue;

@end
