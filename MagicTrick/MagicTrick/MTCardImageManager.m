//
//  MTCardImageManager.m
//  MagicTrick
//
//  Created by Will Wu on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTCardImageManager.h"

@interface MTCardImageManager ()

@property (nonatomic, strong) NSDictionary *symmetryMap;

@property (nonatomic, strong, readwrite) NSArray *allCards;

@property (nonatomic, strong, readwrite) NSArray *symmetricalCards;

@property (nonatomic, strong, readwrite) NSArray *asymmetricalCards;

@property (nonatomic, strong, readwrite) NSArray *faceCards;

@end

@implementation MTCardImageManager

+ (instancetype)sharedInstance
{
    static MTCardImageManager *cardImageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cardImageManager = [[self alloc] init];
    });
    return cardImageManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.symmetryMap = @{ @"clubs_2.png" : @(YES),
                              @"clubs_3.png" : @(NO),
                              @"clubs_4.png" : @(YES),
                              @"clubs_5.png" : @(NO),
                              @"clubs_6.png" : @(NO),
                              @"clubs_7.png" : @(NO),
                              @"clubs_8.png" : @(YES),
                              @"clubs_9.png" : @(NO),
                              @"clubs_10.png" : @(YES),
                              @"clubs_j.png" : @(YES),
                              @"clubs_q.png" : @(NO),
                              @"clubs_k.png" : @(NO),
                              @"clubs_a.png" : @(NO),
                              
                              @"diamonds_2.png" : @(YES),
                              @"diamonds_3.png" : @(YES),
                              @"diamonds_4.png" : @(YES),
                              @"diamonds_5.png" : @(YES),
                              @"diamonds_6.png" : @(YES),
                              @"diamonds_7.png" : @(NO),
                              @"diamonds_8.png" : @(YES),
                              @"diamonds_9.png" : @(YES),
                              @"diamonds_10.png" : @(YES),
                              @"diamonds_j.png" : @(YES),
                              @"diamonds_q.png" : @(YES),
                              @"diamonds_k.png" : @(YES),
                              @"diamonds_a.png" : @(YES),
                              
                              @"hearts_2.png" : @(YES),
                              @"hearts_3.png" : @(NO),
                              @"hearts_4.png" : @(YES),
                              @"hearts_5.png" : @(NO),
                              @"hearts_6.png" : @(NO),
                              @"hearts_7.png" : @(NO),
                              @"hearts_8.png" : @(NO),
                              @"hearts_9.png" : @(NO),
                              @"hearts_10.png" : @(YES),
                              @"hearts_j.png" : @(YES),
                              @"hearts_q.png" : @(YES),
                              @"hearts_k.png" : @(YES),
                              @"hearts_a.png" : @(NO),
                              
                              @"spades_2.png" : @(YES),
                              @"spades_3.png" : @(NO),
                              @"spades_4.png" : @(YES),
                              @"spades_5.png" : @(NO),
                              @"spades_6.png" : @(NO),
                              @"spades_7.png" : @(NO),
                              @"spades_8.png" : @(YES),
                              @"spades_9.png" : @(NO),
                              @"spades_10.png" : @(YES),
                              @"spades_j.png" : @(YES),
                              @"spades_q.png" : @(YES),
                              @"spades_k.png" : @(YES),
                              @"spades_a.png" : @(NO)};
        
        [self initializeCards];
    }
    return self;
}

- (void)initializeCards
{
    NSMutableArray *allCards = [[NSMutableArray alloc] init];
    NSMutableArray *symmetricalCards = [[NSMutableArray alloc] init];
    NSMutableArray *asymmetricalCards = [[NSMutableArray alloc] init];
    NSMutableArray *faceCards = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 14; i++) {
        MTCard *clubsCard = [self cardWithSuit:MTCardSuitClubs andValue:i];
        MTCard *diamondsCard = [self cardWithSuit:MTCardSuitDiamonds andValue:i];
        MTCard *heartsCard = [self cardWithSuit:MTCardSuitHearts andValue:i];
        MTCard *spadesCard = [self cardWithSuit:MTCardSuitSpades andValue:i];

        [allCards addObject:clubsCard];
        [allCards addObject:diamondsCard];
        [allCards addObject:heartsCard];
        [allCards addObject:spadesCard];
    }
    
    self.allCards = [allCards copy];
    
    for (MTCard *card in self.allCards) {
        
        if (card.cardValue <= 10) {
            if (card.symmetrical) {
                [symmetricalCards addObject:card];
            }
            
            else if (!card.symmetrical) {
                [asymmetricalCards addObject:card];
            }
        }
        // If card is a face card
        if (card.cardValue > 10) {
            [faceCards addObject:card];
        }
    }
    
    self.symmetricalCards = [symmetricalCards copy];
    self.asymmetricalCards = [asymmetricalCards copy];
    self.faceCards = [faceCards copy];
}

- (MTCard *)cardWithSuit:(MTCardSuit)cardSuit andValue:(NSInteger)cardValue
{
    MTCard *card = [[MTCard alloc] init];
    card.cardSuit = cardSuit;
    card.cardValue = cardValue;
    card.cardImage = [self imageForCardSuit:cardSuit andCardValue:cardValue];
    card.symmetrical = [self symmetricalForCardSuit:cardSuit andCardValue:cardValue];
    return card;
}

#pragma mark - Helper methods

- (BOOL)symmetricalForCardSuit:(MTCardSuit)cardSuit andCardValue:(NSInteger)cardValue
{
    NSString *filename = [self filenameForCardSuit:cardSuit andCardValue:cardValue];
    BOOL symmetrical = [self.symmetryMap[filename] boolValue];
    return symmetrical;
}

- (NSString *)filenameForCardSuit:(MTCardSuit)cardSuit andCardValue:(NSInteger)cardValue
{
    NSString *imageFilename = @"";
    
    switch (cardSuit) {
        case MTCardSuitClubs:
        {
            imageFilename = [imageFilename stringByAppendingString:@"clubs_"];
            break;
        }
        case MTCardSuitDiamonds:
        {
            imageFilename = [imageFilename stringByAppendingString:@"diamonds_"];
            break;
        }
        case MTCardSuitHearts: {
            imageFilename = [imageFilename stringByAppendingString:@"hearts_"];
            break;
        }
        case MTCardSuitSpades: {
            imageFilename = [imageFilename stringByAppendingString:@"spades_"];
            break;
        }
        default:
            break;
    }
    
    if (cardValue >= 2 && cardValue <= 10) {
        imageFilename = [imageFilename stringByAppendingString:[NSString stringWithFormat:@"%zd.png", cardValue]];
    } else if (cardValue == 1) {
        imageFilename = [imageFilename stringByAppendingString:@"a.png"];
    } else if (cardValue == 11) {
        imageFilename = [imageFilename stringByAppendingString:@"j.png"];
    } else if (cardValue == 12) {
        imageFilename = [imageFilename stringByAppendingString:@"q.png"];
    } else if (cardValue == 13) {
        imageFilename = [imageFilename stringByAppendingString:@"k.png"];
    }

    return imageFilename;
}

- (UIImage *)imageForCardSuit:(MTCardSuit)cardSuit andCardValue:(NSInteger)cardValue
{
    NSString *imageFilename = [self filenameForCardSuit:cardSuit andCardValue:cardValue];
    UIImage *cardImage = [UIImage imageNamed:imageFilename];
    NSAssert(cardImage, @"Can't find card image with that filename");
    return cardImage;
}

@end
