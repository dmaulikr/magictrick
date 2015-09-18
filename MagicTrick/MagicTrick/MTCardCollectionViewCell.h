//
//  MTCardCollectionViewCell.h
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCard.h"

@interface MTCardCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MTCard *card;

@property (nonatomic, assign, readonly) BOOL faceDown;

- (void)flipCard;

@end
