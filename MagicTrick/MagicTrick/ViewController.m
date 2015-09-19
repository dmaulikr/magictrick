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
#import "MTAnimatingStarView.h"
#import "MTCardFlowLayout.h"
#import "SCGrowingButton.h"
#import "MTSoundManager.h"

@import AVFoundation;

static CGFloat const kInterCardSpacing = 15.0f;
static NSUInteger const kNumberOfGameCards = 5;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSUInteger numberCardsShowing;

@property (nonatomic, strong) MTCardImageManager *cardManager;

@property (nonatomic, strong) MTAnimatingStarView *backgroundStarView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *gameCards;

@property (nonatomic, assign) BOOL isFirstCardFace;

@property (nonatomic, assign) BOOL cardsReset;

@property (nonatomic, assign) NSInteger firstCardIndex;

@property (nonatomic, strong) SCGrowingButton *homeButton;

@end

@implementation ViewController

- (id)init
{
    self = [super init];

    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
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

    self.backgroundStarView = [[MTAnimatingStarView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundStarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.backgroundStarView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UIImage *homeImage = [UIImage imageNamed:@"homeButton.png"];
    self.homeButton =
        [[SCGrowingButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (homeImage.size.height) - 40,
                                                          homeImage.size.width + 40, homeImage.size.height + 40)];
    self.homeButton.image = homeImage;
    self.homeButton.imageInset = CGSizeMake(20, 20);
    self.homeButton.maximumScale = 1.05f;
    self.homeButton.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, self.homeButton.center.y);
    [self.homeButton addTarget:self action:@selector(home:)];
    [self.view addSubview:self.homeButton];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initializeCardViews];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.backgroundStarView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.backgroundStarView stopAnimating];
}

#pragma mark - Navigation methods

- (void)home:(UIButton *)button
{
    [self.delegate cardViewControllerDidDismiss:self];
    self.delegate = nil;
}

- (void)initializeCardViews
{
    MTCardFlowLayout *flowLayout = [[MTCardFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MTCardCollectionViewCell class] forCellWithReuseIdentifier:@"cardCell"];
    self.collectionView.alpha = 1.0f;
    [self.view insertSubview:self.collectionView belowSubview:self.homeButton];

    [self animateNextCardIntoView];
}

- (void)animateNextCardIntoView
{
    if (self.numberCardsShowing < 5) {
        [[MTSoundManager sharedInstance] playSound:MTSoundCardDeal];
        
        [UIView animateWithDuration:0.17f
                         animations:^{
                             [self.collectionView performBatchUpdates:^{
                                 self.numberCardsShowing++;
                                 [self.collectionView insertItemsAtIndexPaths:@[
                                     [NSIndexPath indexPathForItem:self.numberCardsShowing - 1 inSection:0]
                                 ]];
                             } completion:^(BOOL finished) {
                                 [self animateNextCardIntoView];
                             }];
                         }];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberCardsShowing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTCardCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cardCell" forIndexPath:indexPath];
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

    [[MTSoundManager sharedInstance] playSound:MTSoundCardFlip];

    // Finally, flip the card over
    [cell flipCard];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cardWidth = 375.0f;
    CGFloat cardHeight = 525.0f;

    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat totalWidth = CGRectGetWidth(screenRect) - 8 * (kInterCardSpacing);

    CGFloat scaledCardWidth = totalWidth / kNumberOfGameCards;
    CGFloat scaledCardHeight = (scaledCardWidth / cardWidth) * cardHeight;

    return CGSizeMake(scaledCardWidth, scaledCardHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    CGFloat cardWidth = 375.0f;
    CGFloat cardHeight = 525.0f;

    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat totalWidth = CGRectGetWidth(screenRect) - 4 * kInterCardSpacing;

    CGFloat scaledCardWidth = totalWidth / kNumberOfGameCards;
    CGFloat scaledCardHeight = (scaledCardWidth / cardWidth) * cardHeight;

    CGFloat verticalMargin = (CGRectGetHeight(screenRect) - scaledCardHeight) / 2;

    return UIEdgeInsetsMake(verticalMargin, 2 * kInterCardSpacing, verticalMargin, 2 * kInterCardSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

// call this function when a user taps a card. know which index was tapped (left being 0, right being 4)
- (void)cardTapped:(NSInteger)index
{
    _cardsReset = [self isAllCardsFaceDown];

    // we know if it's first card tapped or not based on if cards have been reset (all were facing down)
    if (_cardsReset) {
        [self chooseFirstCard:index];
    } else {
        [self chooseCard:index];
    }
}

- (MTCard *)chooseCardFromArray:(NSArray *)cardsArray
{
    NSUInteger randomIndex = arc4random() % [cardsArray count];

    MTCard *card = cardsArray[randomIndex];

    while ([_gameCards containsObject:card]) {
        NSUInteger randomIndex = arc4random() % [cardsArray count];
        card = cardsArray[randomIndex];
    }

    return card;
}

- (void)chooseCard:(NSInteger)index
{
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
- (void)chooseFirstCard:(NSInteger)index
{
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
- (BOOL)thisWillFlipAQuarter
{
    int x = arc4random() % 2;

    if (x == 1) {
        return YES; // 25% of the time you get 0
    } else {
        return NO; // the other 25%, when you get 1
    }
}

// it's like rolling a dice with yes/no values. lol.
- (BOOL)thisWillRollADice
{
    int x = arc4random() % 6;

    if (x < 2) {
        return YES;
    } else {
        return NO;
    }
}

// checks to see if all cards are face down
- (BOOL)isAllCardsFaceDown
{
    for (MTCardCollectionViewCell *cell in self.collectionView.visibleCells) {
        if (!cell.faceDown) {
            return NO;
        }
    }
    _firstCardIndex = -1;
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
