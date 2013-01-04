//
//  TCButton.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/29/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCButton.h"

#define TCBUTTON_LINE_WIDTH 3

@implementation TCButton

- (void)commonInit {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGRect inset = CGRectInset(self.bounds, TCBUTTON_LINE_WIDTH, TCBUTTON_LINE_WIDTH);
	[[UIColor redColor] setStroke];
    [[UIColor redColor] setFill];
    UIBezierPath* rrect = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:7];
    [rrect setLineWidth:TCBUTTON_LINE_WIDTH];
    [rrect stroke];
	UIImage* offImage = UIGraphicsGetImageFromCurrentImageContext();
    [rrect fill];
    UIImage* onImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	[self setBackgroundImage:offImage forState:UIControlStateNormal];
    [self setBackgroundImage:onImage forState:UIControlStateSelected];
    
    //self.adjustsImageWhenHighlighted = NO;
    [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 24];
    
    [self addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPress:(UIButton*)sender {
    self.selected = !self.selected;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
