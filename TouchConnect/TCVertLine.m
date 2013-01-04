//
//  TCVertLine.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/31/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCVertLine.h"

#define VERTLINE_LINE_WIDTH 7.0

@implementation TCVertLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor redColor] setStroke];
    UIBezierPath* line = [UIBezierPath bezierPath];
    if (self.bounds.size.width > self.bounds.size.height) {
        [line moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [line addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height / 2)];
    } else {
        [line moveToPoint:CGPointMake(self.bounds.size.width / 2, 0)];
        [line addLineToPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height)];
    }
    [line setLineWidth:VERTLINE_LINE_WIDTH];
    [line stroke];
}

@end
