//
//  MTCard.h
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSUInteger, MTCardSuit) {
    MTCardSuitClubs,
    MTCardSuitDiamonds,
    MTCardSuitHearts,
    MTCardSuitSpades
};

@interface MTCard : NSObject

@property (nonatomic, assign) MTCardSuit cardSuit;

@property (nonatomic, assign) NSInteger cardValue;

@property (nonatomic, strong) UIImage *cardImage;

@property (nonatomic, assign) BOOL symmetrical;

@end
