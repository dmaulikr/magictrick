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

@property (nonatomic, strong) NSSet *asymmetricalCards;
@property (nonatomic, strong) NSSet *faceCards;
@property (nonatomic, strong) NSSet *allCards;

@property BOOL isFirstCardFace;
@property BOOL cardsReset;

@property (nonatomic, strong) NSArray *gameCards;

@end


@implementation ViewController


- (id)init {
    self = [super init];
    
    _gameCards = [[NSArray alloc] init];
    
    
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
    return YES;
}

- (void)cardTapped {
    _cardsReset = [self isAllCardsFaceDown];
    
    if (_cardsReset) {
        
    }
}

// only execute if cards are reset
- (void)chooseFirstCard {
    // lol janky random number
    NSInteger randomNumber = arc4random() % 16;
    
    if (randomNumber < 7) {
        _isFirstCardFace = YES;
        
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
