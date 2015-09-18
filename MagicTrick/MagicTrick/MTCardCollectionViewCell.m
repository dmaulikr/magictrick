//
//  MTCardCollectionViewCell.m
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTCardCollectionViewCell.h"

@interface MTCardCollectionViewCell ()

@property (nonatomic, strong) UIImageView *frontImageView;

@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, assign, readwrite) BOOL faceDown;

@end

@implementation MTCardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 4.0f;
        
        self.faceDown = YES;

        [self initializeImageViews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backImageView.frame = self.frontImageView.frame = self.contentView.bounds;

}

- (void)initializeImageViews
{
    self.frontImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.frontImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.frontImageView];
    
    self.backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    self.backImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.backImageView];
}

- (void)setCard:(MTCard *)card
{
    if (_card == card) {
        return;
    }
    
    _card = card;
    
    [self.frontImageView performSelectorOnMainThread:@selector(setImage:) withObject:card.cardImage waitUntilDone:YES];
}

- (void)flipCard
{
    self.faceDown = !self.faceDown;
    
    if (self.faceDown) {
        [self.contentView bringSubviewToFront:self.backImageView];
    } else {
        [self.contentView bringSubviewToFront:self.frontImageView];
    }
}

@end
