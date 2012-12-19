//
//  TCFlipsideViewController.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCFlipsideViewController;

@protocol TCFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(TCFlipsideViewController *)controller;
@end

@interface TCFlipsideViewController : UIViewController

@property (weak, nonatomic) id <TCFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
