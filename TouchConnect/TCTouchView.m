//
//  TCTouchView.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCTouchView.h"
#import <QuartzCore/QuartzCore.h>

#define PAN_DEGREES 170
#define PAN_GRID 10
#define TILT_DEGREES 100
#define TILT_GRID 10

#define MARKER_SIZE 40

@implementation TCTouchView {
    CAShapeLayer* gridLayer;
    CAShapeLayer* markerLayer;
    CALayer* shade;
    NSArray* lastOutput;
}

@synthesize delegate = _delegate;

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
    self.multipleTouchEnabled = YES;
    
    self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.clipsToBounds = YES;
    
    gridLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:gridLayer];
    gridLayer.frame = self.bounds;
    gridLayer.shouldRasterize = YES;
    // XXX This fucks it up on iOS 5.1; why???
    gridLayer.rasterizationScale = [UIScreen mainScreen].scale;
    UIColor* gridColor = [UIColor colorWithRed:121/255.0 green:193/255.0 blue:240/255.0 alpha:1];
    gridLayer.strokeColor = gridColor.CGColor;
    
    gridLayer.shadowColor = gridColor.CGColor;
    gridLayer.shadowOffset = CGSizeMake(0, 0);
    gridLayer.shadowOpacity = 1.0;
    gridLayer.shadowRadius = 2.0;
    
    CGMutablePathRef gridPath = CGPathCreateMutable();
    for (int i = 1; i < PAN_DEGREES / PAN_GRID; i++) {
        CGPathMoveToPoint(gridPath, NULL, i * self.bounds.size.width * PAN_GRID / PAN_DEGREES, 0);
        CGPathAddLineToPoint(gridPath, NULL, i * self.bounds.size.width * PAN_GRID / PAN_DEGREES, self.bounds.size.height);
    }
    for (int i = 1; i < TILT_DEGREES / TILT_GRID; i++) {
        CGPathMoveToPoint(gridPath, NULL, 0, i * self.bounds.size.height * TILT_GRID / TILT_DEGREES);
        CGPathAddLineToPoint(gridPath, NULL, self.bounds.size.width, i * self.bounds.size.height * TILT_GRID / TILT_DEGREES);
    }
    gridLayer.path = gridPath;
    
    markerLayer = [[CAShapeLayer alloc] init];
    markerLayer.frame = self.bounds;
    [self.layer addSublayer:markerLayer];
    markerLayer.strokeColor = [UIColor redColor].CGColor;
    markerLayer.lineWidth = 5;
    markerLayer.fillColor = NULL;
    //markerLayer.opaque = NO;
    
    markerLayer.shadowColor = markerLayer.strokeColor;
    markerLayer.shadowOffset = CGSizeMake(0, 0);
    markerLayer.shadowOpacity = 1.0;
    markerLayer.shadowRadius = 3.0;
    
    //[self setMarkers:@[[NSValue valueWithCGPoint:CGPointMake(50, 50)]]];
    
    shade = [[CALayer alloc] init];
    [self.layer addSublayer:shade];
    shade.frame = self.bounds;
    shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    
    [self setShade:NO];

    [self setNeedsDisplay];
}

- (void)setShade:(boolean_t)on {
    
    if (!shade.hidden && !on && lastOutput && [lastOutput count]) {
        NSLog(@"sending last output");
        [_delegate positionsChanged:lastOutput];
    }
    
    shade.hidden = !on;
}



- (void) setMarkers:(NSArray*) points {
    CGMutablePathRef path = CGPathCreateMutable();
    for (NSValue* value in points) {
        CGPoint pt = [value CGPointValue];
        CGPathMoveToPoint(path, NULL, pt.x - MARKER_SIZE, pt.y);
        CGPathAddLineToPoint(path, NULL, pt.x + MARKER_SIZE, pt.y);
        CGPathMoveToPoint(path, NULL, pt.x, pt.y - MARKER_SIZE);
        CGPathAddLineToPoint(path, NULL, pt.x, pt.y + MARKER_SIZE);
    }
    markerLayer.path = path;
}

-(void)handleTouches:(NSSet*)touches withEvent:(UIEvent*)event {
    [self setShade:NO];
    //NSLog(@"Touches: %@", touches);
    //NSLog(@"touches %d event %d", [touches count], [[event touchesForView:self] count]);
    NSMutableArray* output = [[NSMutableArray alloc] init];
    NSMutableArray* markers = [[NSMutableArray alloc] init];
    int i = 0;
    for (UITouch* touch in [event touchesForView:self]) {
        CGPoint loc = [touch locationInView:self];
        [markers addObject:[NSValue valueWithCGPoint:loc]];
        loc.x /= self.bounds.size.width;
        loc.y /= self.bounds.size.height;
        [output addObject:[NSValue valueWithCGPoint:loc]];
        i++;
        if (i >= self.maxTouches) {
            break;
        }
    }
    [self setMarkers:markers];
    lastOutput = output;
    [_delegate positionsChanged:output];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesBegan");
    [_delegate placementStarted];
    [self handleTouches:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesMoved");
    [self handleTouches:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
