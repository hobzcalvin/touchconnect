//
//  TCHueSatPicker.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/23/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCHueSatPicker.h"
#import <QuartzCore/QuartzCore.h>

#define LOUPE_RADIUS 40

@implementation TCHueSatPicker {
    NSMutableArray* loupeLayers;
    UIImageView* bg;
    CALayer* shade;
    NSArray* lastOutput;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    loupeLayers = [[NSMutableArray alloc] init];
    
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    
    bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colormap.png"]];
    [bg setFrame:self.bounds];
    bg.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:bg];
    
    shade = [[CALayer alloc] init];
    [self.layer addSublayer:shade];
    shade.frame = self.bounds;
    shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    
    [self setShade:NO];
    
    self.multipleTouchEnabled = YES;
}

- (void)setShade:(boolean_t)on {
    
    if (!shade.hidden && !on && lastOutput && [lastOutput count]) {
        NSLog(@"sending last output");
        [_delegate hueSatColorsChanged:lastOutput];
    }

    shade.hidden = !on;
}

-(void)handleTouches:(NSSet*)touches withEvent:(UIEvent*)event {
    [self setShade:NO];
    
    //NSLog(@"Touches: %@", touches);
    //NSLog(@"touches %d event %d", [touches count], [[event touchesForView:self] count]);
    NSMutableArray* output = [[NSMutableArray alloc] init];
    CAShapeLayer* curLayer;
    int i = 0;
    for (UITouch* touch in [event touchesForView:self]) {
        CGPoint loc = [touch locationInView:self];
        UIColor* curColor = [UIColor colorWithHue:loc.x / self.bounds.size.width saturation: 1.0 - (loc.y / self.bounds.size.height) brightness:1 alpha:1];
        [output addObject:curColor];
        if ([loupeLayers count] <= i) {
            //NSLog(@"alloc loupelayer");
            curLayer = [[CAShapeLayer alloc] init];
            [loupeLayers addObject:curLayer];
            [self.layer insertSublayer:curLayer below:shade];
            curLayer.frame = self.bounds;
            curLayer.lineWidth = 5;
            curLayer.strokeColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
            curLayer.shadowOpacity = 0.5;
            curLayer.shadowOffset = CGSizeMake(3, 3);
            
            curLayer.actions = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNull null], @"onOrderIn",
                                [NSNull null], @"onOrderOut",
                                [NSNull null], @"sublayers",
                                [NSNull null], @"contents",
                                [NSNull null], @"bounds",
                                [NSNull null], @"frame",
                                [NSNull null], @"position",
                                [NSNull null], @"hidden",
                                [NSNull null], @"fillColor",
                                nil];
        } else {
            curLayer = loupeLayers[i];
        }
        CGRect loupeRect = CGRectMake(loc.x - LOUPE_RADIUS, loc.y - LOUPE_RADIUS, LOUPE_RADIUS * 2, LOUPE_RADIUS * 2);
        curLayer.path = CGPathCreateWithEllipseInRect(loupeRect, NULL);
        curLayer.fillColor = curColor.CGColor;
        curLayer.hidden = NO;
        i++;
        if (i >= self.maxTouches) {
            break;
        }
    }
    while (i < [loupeLayers count]) {
        curLayer = loupeLayers[i];
        curLayer.hidden = YES;
        i++;
    }
    
    lastOutput = output;
    [_delegate hueSatColorsChanged:output];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate changesStarted];
    [self handleTouches:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches withEvent:event];
}
/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 }*/


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
