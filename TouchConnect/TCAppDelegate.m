//
//  TCAppDelegate.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCMainViewController.h"

@implementation TCAppDelegate {
    Server* server;
    TCMainViewController* mainVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    server = [[Server alloc] initWithProtocol:@"TouchConnect"];
    server.payloadSize = 1024;//START HERE: Does this give us enough to send all the touches like we'd want?
    // WELL, it doesn't. because also, it seems to combine several sends into one packet on the other side: 374, 224 here becomes 598.
    // HOWEVER, I can't repro in an ad-hoc network. For now, just always use that?! ick.
    server.delegate = self;
    NSError *error = nil;
    if(![server start:&error]) {
        NSLog(@"error = %@", error);
    }
    
    mainVC = (TCMainViewController*)self.window.rootViewController;
    //mainVC.server = server;
    
    return YES;
}

#pragma mark Server Delegate Methods

- (void)serverRemoteConnectionComplete:(Server *)theServer {
    NSLog(@"Server Started");
    
    [mainVC connectionComplete:theServer];
    // XXX: The outputstream isn't ready to go at this point, which is dumb.
    //[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reportSize) userInfo:nil repeats:NO];
}
- (void)reportSize {
    // this is called when the remote side finishes joining with the socket as
    // notification that the other side has made its connection with this side
    NSError* err;
    [server sendData:[NSKeyedArchiver archivedDataWithRootObject:@{@"viewSize" : [NSValue valueWithCGSize:mainVC.mainView.bounds.size]}] error:&err];
    if (err) {
        NSLog(@"error reporting size: %@", err);
    }
}

- (void)serverStopped:(Server *)server {
    NSLog(@"Server stopped");
    [mainVC connectionLost];
}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict {
    NSLog(@"Server did not start %@", errorDict);
}

- (void)server:(Server *)server didAcceptData:(NSData *)data {
    NSLog(@"Server did accept data %@", data);
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict {
    NSLog(@"Server lost connection %@", errorDict);
    [mainVC connectionLost];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more {
    [server connectToRemoteService:service];
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more {
}

#pragma mark -

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
