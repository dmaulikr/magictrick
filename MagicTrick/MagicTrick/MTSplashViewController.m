//
//  MTSplashViewController.m
//  MagicTrick
//
//  Created by Will Wu on 9/18/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import "MTSplashViewController.h"
#import "MTAnimatingCardView.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MTSplashViewController ()

@property (nonatomic, strong) MTAnimatingCardView *backgroundCardView;

@end

@implementation MTSplashViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x332c4c);

    self.backgroundCardView = [[MTAnimatingCardView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundCardView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.backgroundCardView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.backgroundCardView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
