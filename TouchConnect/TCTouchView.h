//
//  TCTouchView.h
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchViewDelegate <NSObject>
- (void)positionsChanged:(NSArray*)positions;
- (void)placementStarted;
@end

@interface TCTouchView : UIView {
    id<TouchViewDelegate> __weak _delegate; // see docs on delegate protocol
}

- (void)setShade:(boolean_t)on;


@property(nonatomic, weak) id<TouchViewDelegate> delegate;
@property (assign, nonatomic) uint8_t maxTouches;

@end
