//
//  TCMainViewController.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCFlipsideViewController.h"

@interface TCMainViewController : UIViewController <TCFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
