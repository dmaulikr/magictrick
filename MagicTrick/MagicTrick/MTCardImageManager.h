//
//  MTCardImageManager.h
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTCard.h"

@import UIKit;

@interface MTCardImageManager : NSObject

@property (nonatomic, strong, readonly) NSArray *allCards;

@property (nonatomic, strong, readonly) NSArray *symmetricalCards;

@property (nonatomic, strong, readonly) NSArray *asymmetricalCards;

@property (nonatomic, strong, readonly) NSArray *faceCards;

+ (instancetype)sharedInstance;

@end
