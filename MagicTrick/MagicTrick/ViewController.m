//
//  ViewController.m
//  MagicTrick
//
//  Created by Lucy Guo on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "ViewController.h"
#import "card.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *asymmetricalCards;
@property (nonatomic, strong) NSMutableArray *symmetricalCards;
@property (nonatomic, strong) NSMutableArray *faceCards;
@property (nonatomic, strong) NSMutableArray *allCards;

@property BOOL isFirstCardFace;
@property BOOL cardsReset;
@property NSInteger firstCardIndex;

@property (nonatomic, strong) NSMutableArray *gameCards;

@end


@implementation ViewController


- (id)init {
    self = [super init];
    
    // setup initial game cards (just mark everything as flipped down, even if they dont have face value)
    [self setupGameCards];
    return self;
}

// when initialized, all cards are face down

- (void)setupGameCards {
    _gameCards = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        
        // TODO: Fix frame
        card *newCard = [[card alloc] initWithFrame:CGRectZero];
        newCard.faceDown = YES;
    }
}

// checks to see if all cards are face down
- (BOOL)isAllCardsFaceDown {
    for (int i = 0; i < 5; i++) {
        card *gameCard = _gameCards[i];
        if (!gameCard.faceDown) {
            return NO;
        }
    }
    _firstCardIndex = -1;
    return YES;
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

- (void)chooseCard:(NSInteger)index {
    // first card chosen was a face, so all cards before must be symmetrical
    if (index < _firstCardIndex && _isFirstCardFace) {
        NSUInteger randomIndex = arc4random() % [_symmetricalCards count];
        _gameCards[index] = _symmetricalCards[randomIndex];
    }
    // first card chosen was asymmetrical, so face cards or symmetrical cards work
    else if (index < _firstCardIndex) {
        // randomly choose face or symmetrical
        if ([self thisWillFlipAQuarter]) {
            NSUInteger randomIndex = arc4random() % [_symmetricalCards count];
            _gameCards[index] = _symmetricalCards[randomIndex];
        } else {
            NSUInteger randomIndex = arc4random() % [_faceCards count];
            _gameCards[index] = _faceCards[randomIndex];
        }
    }
    // woohoo it's after the first index so we can choose any card!!
    else {
        NSUInteger randomIndex = arc4random() % [_allCards count];
        _gameCards[index] = _allCards[randomIndex];
    }
}

// only execute if cards are reset
- (void)chooseFirstCard:(NSInteger)index {
    _firstCardIndex = index;
    
    // randomly chooses whether to select a face card or asymmetrical card
    if ([self thisWillRollADice]) {
        _isFirstCardFace = YES;
        
        // set first card to random face card
        NSUInteger randomIndex = arc4random() % [_faceCards count];
        _gameCards[_firstCardIndex] = _faceCards[randomIndex];
        
    } else {
        _isFirstCardFace = NO;
        
        // set first card to random asymmetrical card
        NSUInteger randomIndex = arc4random() % [_asymmetricalCards count];
        _gameCards[_firstCardIndex] = _faceCards[randomIndex];
    }
    
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
