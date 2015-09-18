//
//  ViewController.m
//  MagicTrick
//
//  Created by Lucy Guo on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "ViewController.h"
#import "card.h"
#import "MTCardCollectionViewCell.h"
#import "MTCardImageManager.h"

static CGFloat const kInterCardSpacing = 15.0f;
static NSUInteger const kNumberOfGameCards = 5;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MTCardImageManager *cardManager;

@property (nonatomic, strong) UICollectionView *collectionView;

@property BOOL isFirstCardFace;
@property BOOL cardsReset;
@property NSInteger firstCardIndex;

@property (nonatomic, strong) NSMutableArray *gameCards;

@end


@implementation ViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        self.cardManager = [MTCardImageManager sharedInstance];
        self.gameCards = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 5; i++) {
            [self.gameCards addObject:[[NSObject alloc] init]];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeViews];
}

- (void)initializeViews
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MTCardCollectionViewCell class] forCellWithReuseIdentifier:@"cardCell"];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Calculate the next card to show, according to Lucy's algorithm
    [self cardTapped:indexPath.item];
    
    MTCardCollectionViewCell *cell = (MTCardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    // Here we have to get the next appropriate card to display, before flipping the card over
    cell.card = [self.gameCards objectAtIndex:indexPath.item];

    // Finally, flip the card over
    [cell flipCard];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cardWidth = 375.0f;
    CGFloat cardHeight = 525.0f;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat totalWidth = CGRectGetWidth(screenRect) - 4 * kInterCardSpacing;
    
    CGFloat scaledCardWidth = totalWidth / kNumberOfGameCards;
    CGFloat scaledCardHeight = (scaledCardWidth / cardWidth) * cardHeight;
    
    return CGSizeMake(scaledCardWidth, scaledCardHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat cardWidth = 375.0f;
    CGFloat cardHeight = 525.0f;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat totalWidth = CGRectGetWidth(screenRect) - 4 * kInterCardSpacing;
    
    CGFloat scaledCardWidth = totalWidth / kNumberOfGameCards;
    CGFloat scaledCardHeight = (scaledCardWidth / cardWidth) * cardHeight;
    
    CGFloat verticalMargin = (CGRectGetHeight(screenRect) - scaledCardHeight) / 2;
    
    return UIEdgeInsetsMake(verticalMargin, kInterCardSpacing, verticalMargin, kInterCardSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

// call this function when a user taps a card. know which index was tapped (left being 0, right being 4)
- (void)cardTapped:(NSInteger)index {
    _cardsReset = [self isAllCardsFaceDown];
    
    // we know if it's first card tapped or not based on if cards have been reset (all were facing down)
    if (_cardsReset) {
        [self chooseFirstCard:index];
    } else {
        [self chooseCard:index];
    }
}

- (MTCard *)chooseCardFromArray:(NSArray *)cardsArray {
    NSUInteger randomIndex = arc4random() % [cardsArray count];
    
    MTCard *card = cardsArray[randomIndex];
    
    while ([_gameCards containsObject:card]) {
        NSUInteger randomIndex = arc4random() % [cardsArray count];
        card = cardsArray[randomIndex];
    }
    
    return card;
}

- (void)chooseCard:(NSInteger)index {
    // first card chosen was a face, so all cards before must be symmetrical
    if (index < _firstCardIndex && _isFirstCardFace) {
        MTCard *card = [self chooseCardFromArray:self.cardManager.symmetricalCards];

        _gameCards[index] = card;
    }
    // first card chosen was asymmetrical, so face cards or symmetrical cards work
    else if (index < _firstCardIndex) {
        // randomly choose face or symmetrical
        if ([self thisWillFlipAQuarter]) {
            MTCard *card = [self chooseCardFromArray:self.cardManager.symmetricalCards];
            
            _gameCards[index] = card;
        } else {
            MTCard *card = [self chooseCardFromArray:self.cardManager.faceCards];
            
            _gameCards[index] = card;
        }
    }
    // face card first card, all cards after must be symmetrical
    else if (_isFirstCardFace) {
        MTCard *card = [self chooseCardFromArray:self.cardManager.symmetricalCards];
        
        _gameCards[index] = card;
    }
    // asymmetrical card first, any cards after
    else {
        MTCard *card = [self chooseCardFromArray:self.cardManager.allCards];
        
        _gameCards[index] = card;
    }
}

// only execute if cards are reset
- (void)chooseFirstCard:(NSInteger)index {
    _firstCardIndex = index;
    
    // randomly chooses whether to select a face card or asymmetrical card
    if ([self thisWillRollADice]) {
        _isFirstCardFace = YES;
        
        // set first card to random face card
        NSUInteger randomIndex = arc4random() % [self.cardManager.faceCards count];
        _gameCards[_firstCardIndex] = self.cardManager.faceCards[randomIndex];
        
    } else {
        _isFirstCardFace = NO;
        
        // set first card to random asymmetrical card
        NSUInteger randomIndex = arc4random() % [self.cardManager.asymmetricalCards count];
        _gameCards[_firstCardIndex] = self.cardManager.asymmetricalCards[randomIndex];
    }
    
}

#pragma mark - Card Algorithm Helper methods

// it's like flipping a quarter. lol.
- (BOOL)thisWillFlipAQuarter {
    int x = arc4random() % 2;
    
    if (x == 1) {
        return YES; // 25% of the time you get 0
    } else {
        return NO; // the other 25%, when you get 1
    }
}

// it's like rolling a dice with yes/no values. lol.
- (BOOL)thisWillRollADice {
    int x = arc4random() % 6;
    
    if (x < 2) {
        return YES;
    } else {
        return NO;
    }
}

// checks to see if all cards are face down
- (BOOL)isAllCardsFaceDown {
    for (MTCardCollectionViewCell *cell in self.collectionView.visibleCells) {
        if (!cell.faceDown) {
            return NO;
        }
    }
    _firstCardIndex = -1;
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
