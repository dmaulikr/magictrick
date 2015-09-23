//
//  MTCardFlowLayout.m
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTCardFlowLayout.h"

@implementation MTCardFlowLayout

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [[self layoutAttributesForItemAtIndexPath:itemIndexPath] copy];
    
    attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
    
    return attr;
}

@end
