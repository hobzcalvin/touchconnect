//
//  TCSlider.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/30/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSlider;
@protocol SliderDelegate <NSObject>
- (void)sliderValueChanged:(float)value from:(TCSlider*)sender;
@end

@interface TCSlider : UIView

@property (assign, nonatomic) id<SliderDelegate> delegate;
@property (nonatomic) float topLine;
@property (nonatomic, strong) NSString* vertLabel;
@property (nonatomic, strong) NSString* topText;
@property (nonatomic, strong) NSString* botText;
@property (nonatomic, strong) NSNumber* fontSize;

@end
