//
//  TCHueSatPicker.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/23/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HueSatPickerDelegate <NSObject>
- (void)hueSatColorsChanged:(NSArray*)colors;
- (void)changesStarted;
@end

@interface TCHueSatPicker : UIView {
//    id<HueSatPickerDelegate> delegate;
}

- (void)setShade:(boolean_t)on;


@property (assign, nonatomic) id<HueSatPickerDelegate> delegate;
@property (assign, nonatomic) uint8_t maxTouches;

@end
