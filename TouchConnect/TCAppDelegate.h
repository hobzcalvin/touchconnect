//
//  TCAppDelegate.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"

@interface TCAppDelegate : UIResponder <UIApplicationDelegate, ServerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
