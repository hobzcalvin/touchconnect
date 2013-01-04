//
//  TCMainViewController.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCFlipsideViewController.h"
#import "TCHueSatPicker.h"
#import "TCTouchView.h"
#import "TCPocketColorPicker.h"
#import "TCSlider.h"
#import "Server.h"

@interface TCMainViewController : UIViewController <TCFlipsideViewControllerDelegate, UIPopoverControllerDelegate, TouchViewDelegate, HueSatPickerDelegate, PocketColorPickerDelegate, SliderDelegate>

- (void)connectionComplete:(Server*)theServer;
- (void)connectionLost;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (nonatomic, strong) Server *server;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end
