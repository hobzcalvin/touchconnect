//
//  TCFlipsideViewController.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCFlipsideViewController.h"

@interface TCFlipsideViewController ()

@end

@implementation TCFlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
