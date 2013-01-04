//
//  TCSlider.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/30/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCSlider.h"

#define SLIDER_LINE_WIDTH 3.0
#define SLIDER_END_MARGIN 20.0

@implementation TCSlider {
    UIView* offView;
}


- (void)awakeFromNib {
    self.backgroundColor = [UIColor blackColor];
    
    self.clipsToBounds = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGRect inset = CGRectInset(self.bounds, SLIDER_LINE_WIDTH * 2, SLIDER_END_MARGIN);
    [[UIColor redColor] setStroke];
    [[UIColor redColor] setFill];
    UIBezierPath* rrect = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:7];
    [rrect setLineWidth:SLIDER_LINE_WIDTH];
    [rrect stroke];
    
    UIBezierPath* topLinePath = nil;
    if (self.topLine) {
        topLinePath = [UIBezierPath bezierPath];
        [topLinePath setLineWidth:SLIDER_LINE_WIDTH];
        float topLineY = inset.origin.y + inset.size.height * (1.0 - self.topLine);
        [topLinePath moveToPoint:CGPointMake(CGRectGetMinX(inset) + SLIDER_LINE_WIDTH / 2, topLineY)];
        [topLinePath addLineToPoint:CGPointMake(CGRectGetMaxX(inset) - SLIDER_LINE_WIDTH / 2, topLineY)];
        [topLinePath stroke];
    }
    UIFont* font = [UIFont boldSystemFontOfSize:(self.fontSize ? [self.fontSize intValue] : 18)];
    CGSize topSize;
    CGSize botSize;
    if (self.topText) {
        topSize = [self.topText sizeWithFont:font];
        [self.topText drawAtPoint:CGPointMake((self.bounds.size.width - topSize.width) / 2, SLIDER_END_MARGIN + SLIDER_LINE_WIDTH) withFont:font];
    }
    if (self.botText) {
        botSize = [self.botText sizeWithFont:font];
        [self.botText drawAtPoint:CGPointMake((self.bounds.size.width - botSize.width) / 2, self.bounds.size.height - SLIDER_END_MARGIN - SLIDER_LINE_WIDTH - botSize.height) withFont:font];
    }
    
    UIImageView* offImageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    
    // Now draw the "on" image and place the opposite-colored decorations.
    [rrect fill];
    [self.backgroundColor setFill];
    [self.backgroundColor setStroke];
    if (topLinePath) {
        [topLinePath stroke];
    }
    if (self.topText) {
        [self.topText drawAtPoint:CGPointMake((self.bounds.size.width - topSize.width) / 2, SLIDER_END_MARGIN + SLIDER_LINE_WIDTH) withFont:font];
    }
    if (self.botText) {
        [self.botText drawAtPoint:CGPointMake((self.bounds.size.width - botSize.width) / 2, self.bounds.size.height - SLIDER_END_MARGIN - SLIDER_LINE_WIDTH - botSize.height) withFont:font];
    }
    UIImageView* onImageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    offView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:offView];
    [offView addSubview:offImageView];
    offView.clipsToBounds = YES;
    offView.opaque = YES;
    offView.backgroundColor = self.backgroundColor;
    
    [self addSubview:onImageView];
    [self addSubview:offView];
    offView.frame = CGRectMake(0, 0, self.bounds.size.width, 0);
}

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![touches count]) {
        return;
    }
    UITouch* touch = [touches anyObject];
    float height = MIN(self.bounds.size.height, MAX(0, [touch locationInView:self].y));
    offView.frame = CGRectMake(0, 0, self.bounds.size.width, height);

float value = MIN(1.0, MAX(0, 1.0 - ([touch locationInView:self].y - (SLIDER_END_MARGIN + SLIDER_LINE_WIDTH / 2)) / (self.bounds.size.height - 2 * SLIDER_END_MARGIN - SLIDER_LINE_WIDTH)));
    [self.delegate sliderValueChanged:value from:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches withEvent:event];
}
/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}*/



- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The rest will get done in awakeFromNib.
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
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
