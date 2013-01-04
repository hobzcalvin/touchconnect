//
//  TCPocketColorPicker.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/30/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCPocketColorPicker;

@protocol PocketColorPickerDelegate <NSObject>
- (void)pocketColorDMXChanged:(NSArray*)dmxOutputs from:(TCPocketColorPicker*)sender;
@end

@interface TCPocketColorPicker : UIView

@property (assign, nonatomic) id<PocketColorPickerDelegate> delegate;
@property (assign, nonatomic) uint8_t maxColors;
@property (nonatomic) BOOL fx;

@end
