//
//  ViewController.h
//  MagicTrick
//
//  Created by Lucy Guo on 9/17/15.
//  Copyright (c) 2015 Lucy Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@protocol MTCardViewControllerDelegate <NSObject>

- (void)cardViewControllerDidDismiss:(ViewController *)cardViewController;

@end

@interface ViewController : UIViewController

@property (nonatomic, weak) id<MTCardViewControllerDelegate> delegate;

@end

