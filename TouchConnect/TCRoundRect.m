//
//  TCRoundRect.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/31/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCRoundRect.h"

#define ROUNDRECT_LINE_WIDTH 3.0

@implementation TCRoundRect

/*- (void)commonInit {
    self.backgroundColor = [UIColor blackColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect inset = CGRectInset(self.bounds, ROUNDRECT_LINE_WIDTH, ROUNDRECT_LINE_WIDTH);
    [[UIColor redColor] setStroke];
    UIBezierPath* rrect = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:7];
    [rrect setLineWidth:ROUNDRECT_LINE_WIDTH];
    [rrect stroke];
}


@end
