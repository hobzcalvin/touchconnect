//
//  TCPocketColorPicker.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/30/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCPocketColorPicker.h"
#import <QuartzCore/QuartzCore.h>

#define COLORBUTTON_LINE_WIDTH 3.0
#define COLORBUTTON_SPACING 5.0
#define COLORBUTTON_TEXT_BUTTON_WIDTH 85.0

@interface TCColorButton : UIImageView
@property (assign, nonatomic) uint8_t dmx;
@end

@implementation TCColorButton

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color dmx:(uint8_t)dmx {
    self = [super initWithFrame:frame];
    if (self) {
        self.dmx = dmx;
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [[UIScreen mainScreen] scale]);
        CGRect inset = CGRectInset(self.bounds, COLORBUTTON_LINE_WIDTH * 2, COLORBUTTON_LINE_WIDTH * 2);
        [color setStroke];
        [color setFill];
        UIBezierPath* rrect = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:7];
        [rrect setLineWidth:COLORBUTTON_LINE_WIDTH];
        [rrect stroke];
        CGRect tiny = CGRectInset(inset, 10, 10);
        [[UIBezierPath bezierPathWithRect:tiny] fill];
        UIImage* offImage = UIGraphicsGetImageFromCurrentImageContext();
        [rrect fill];
        UIImage* onImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.image = offImage;
        self.highlightedImage = onImage;
    }
    return self;
}

/*- (void)buttonPress:(UIButton*)sender {
    self.selected = !self.selected;
}*/


@end

@implementation TCPocketColorPicker {
    NSArray* colors;
    //CGRect colorButtonFrame;
    CALayer* colorButtonShade;
    UIButton* sticky;
    UIButton* cycle;
    UIButton* sound;
    NSMutableArray* stickyFIFO;
}

#define colorElem(name, red, grn, blu, dmx) [@[@name, [UIColor colorWithRed:red/255.0 green:grn/255.0 blue:blu/255.0 alpha:1], @dmx] mutableCopy]


- (void)awakeFromNib {
    int rows, cols;
    
    if (self.fx) {
        colors = @[
        colorElem("RED",            255, 0, 0, 8),
        colorElem("GREEN",            0, 255, 0, 25),
        colorElem("BLUE",            0, 0, 255, 42),
        colorElem("RGB",            110, 110, 110, 178),
        colorElem("LT RED",            255, 127, 127, 110),
        colorElem("LT GREEN",            127, 255, 127, 144),
        colorElem("LT BLUE",            127, 127, 255, 161),
        colorElem("WHITE",            160, 160, 160, 59),
        colorElem("MAGENTA",            255, 0, 255, 93),
        colorElem("YELLOW",            255, 255, 0, 76),
        colorElem("CYAN",            0, 255, 255, 127),
        colorElem("ALL ON",            255, 255, 255, 246),
        colorElem("LT YELLOW",            255, 255, 127, 195),
        colorElem("LT CYAN",            127, 255, 255, 229),
        ];
        
        rows = 4;
        cols = ceilf((float)[colors count] / rows);
    } else {
        colors = @[
        colorElem("WHITE", 255, 255, 255, 2),
        colorElem("GREEN", 0, 255, 0, 10),
        colorElem("ORANGE", 255, 127, 0, 18),
        colorElem("BLUE", 0, 0, 255, 26),
        colorElem("YELLOW", 255, 255, 0, 34),
        colorElem("PINK", 255, 127, 127, 42),
        colorElem("GREEN", 0, 255, 0, 50),
        colorElem("RED", 255, 0, 0, 58),
        colorElem("LT BLUE", 127, 127, 255, 66),
        colorElem("ROSE", 255, 200, 200, 74),
        colorElem("MAGENTA", 255, 0, 255, 82),
        colorElem("PURPLE", 99, 71, 171, 90),
        /*colorElem("YELLOW", 255, 255, 0, 98),
        colorElem("LT GREEN", 127, 255, 127, 106),
        colorElem("ORANGE", 255, 127, 0, 114),
        colorElem("WHITE", 255, 255, 255, 122),*/
        
        /*colorElem("WHITE",          255, 255, 255, 0),
        colorElem("ORANGE 306",     225, 105, 000, 16),
        colorElem("YELLOW 601",     255, 255, 000, 32),
        colorElem("GREEN 204",      000, 255, 000, 48),
        colorElem("UV 108",          99, 071, 171, 64),
        colorElem("MAGENTA 501",    255, 000, 255, 80),
        colorElem("MAGENTA 507",    128, 000, 255, 96),
        colorElem("CYAN 104",       000, 255, 255, 112),
        colorElem("RED 304",        255, 000, 000, 128),
        colorElem("TORQUES 208",    255, 255, 255, 144),
        colorElem("PINK 310",       255, 255, 255, 160),*/
        /*colorElem("YELLOW 603",     255, 255, 255, 176),
         colorElem("BLUE 101",       255, 255, 255, 192),
         colorElem("ORANGE 302",     255, 255, 255, 208),
         colorElem("GREEN 201",      255, 255, 255, 224),*/
        ];
        rows = 1;
        cols = [colors count];
    }
    
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.multipleTouchEnabled = YES;
    
    stickyFIFO = [[NSMutableArray alloc] init];
    
    float buttonSize = self.fx ? self.bounds.size.height / rows : self.bounds.size.width / cols;
    
    colorButtonShade = [[CALayer alloc] init];
    colorButtonShade.frame = CGRectMake(0, self.fx ? 0 : buttonSize, buttonSize * cols, buttonSize * rows);
    colorButtonShade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    colorButtonShade.hidden = YES;
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols && i * cols + j < [colors count]; j++) {
            TCColorButton* but = [[TCColorButton alloc] initWithFrame:CGRectMake(colorButtonShade.frame.origin.x + j * buttonSize,
                                                                                 colorButtonShade.frame.origin.y + i * buttonSize,
                                                                                 buttonSize, buttonSize) color:colors[i * cols + j][1] dmx:[colors[i * cols + j][2] intValue]];
            [colors[i * cols + j] addObject:but];
            [self addSubview:but];            
        }
    }
    
    /*for (int i = 0; i < [colors count]; i++) {
        TCColorButton* but = [[TCColorButton alloc] initWithFrame:CGRectMake(colorButtonShade.frame.origin.x + i * buttonSize,
                                                                             colorButtonShade.frame.origin.y,
                                                                             buttonSize, buttonSize) color:colors[i][1] dmx:[colors[i][2] intValue]];
        [colors[i] addObject:but];
        [self addSubview:but];
    }*/
    
    // Put the shade above the color buttons
    [self.layer addSublayer:colorButtonShade];
    
    if (self.fx) {
        return;
    }
    
    sticky = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:sticky];
    sticky.frame = CGRectMake(self.bounds.size.width - 2 * buttonSize - COLORBUTTON_TEXT_BUTTON_WIDTH, 0, COLORBUTTON_TEXT_BUTTON_WIDTH, buttonSize);
    [self customizeTextButton:sticky];
    [sticky setTitle:@"⇊Sticky" forState:UIControlStateNormal];
    sticky.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    cycle = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:cycle];
    cycle.frame = CGRectMake(CGRectGetMaxX(sticky.frame), 0, buttonSize, buttonSize);
    [self customizeTextButton:cycle];
    [cycle setTitle:@"♺" forState:UIControlStateNormal];
    cycle.titleLabel.font = [UIFont boldSystemFontOfSize:buttonSize / 2];

    sound = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:sound];
    sound.frame = CGRectMake(CGRectGetMaxX(cycle.frame), 0, buttonSize, buttonSize);
    [self customizeTextButton:sound];
    [sound setTitle:@"🔊" forState:UIControlStateNormal];
    sound.titleLabel.font = [UIFont boldSystemFontOfSize:buttonSize / 2];
}

- (void)customizeTextButton:(UIButton*)but {
    UIGraphicsBeginImageContextWithOptions(but.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGRect inset = CGRectInset(but.bounds, COLORBUTTON_LINE_WIDTH * 2, COLORBUTTON_LINE_WIDTH * 2);
    [[UIColor redColor] setStroke];
    [[UIColor redColor] setFill];
    UIBezierPath* rrect = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:7];
    [rrect setLineWidth:COLORBUTTON_LINE_WIDTH];
    [rrect stroke];
    UIImage* offImage = UIGraphicsGetImageFromCurrentImageContext();
    [rrect fill];
    UIImage* onImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [but setBackgroundImage:offImage forState:UIControlStateNormal];
    [but setBackgroundImage:onImage forState:UIControlStateSelected];
    [but addTarget:self action:@selector(toggleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [but setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [but setTitleColor:[but titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [but setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)toggleButtonPress:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    if (sender == cycle || sender == sound) {
        if (sender.selected) {
            colorButtonShade.hidden = NO;
            if (sender == cycle) {
                sound.selected = NO;
                // Send DMX for color cycling
                [self.delegate pocketColorDMXChanged:@[@252] from:self];
            } else {
                cycle.selected = NO;
                // Send DMX for sound control
                [self.delegate pocketColorDMXChanged:@[@255] from:self];
            }
        } else {
            colorButtonShade.hidden = YES;
            // Send DMX for existing color buttons
            NSMutableArray* dmxOutputs = [[NSMutableArray alloc] init];
            for (NSArray* color in colors) {
                TCColorButton* but = color[3];
                if (but.highlighted) {
                    [dmxOutputs addObject:color[2]];
                }
            }
            if (![dmxOutputs count]) {
                // If user untouched everything, make it a blackout (I think?)
                [dmxOutputs addObject:@0];
            }
            [self.delegate pocketColorDMXChanged:dmxOutputs from:self];
        }
    }
}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    boolean_t touchInFrame = NO;
    for (UITouch* touch in touches) {
        if (CGRectContainsPoint(colorButtonShade.frame, [touch locationInView:self])) {
            touchInFrame = YES;
        }
    }
    if (!touchInFrame) {
        return;
    }
    
    colorButtonShade.hidden = YES;
    cycle.selected = NO;
    sound.selected = NO;
    
    NSMutableArray* dmxOutputs = [[NSMutableArray alloc] init];
    for (NSArray* color in colors) {
        TCColorButton* but = color[3];
        boolean_t touched = NO;
        for (UITouch* touch in touches) {
            if (CGRectContainsPoint(but.frame, [touch locationInView:self])) {
                touched = YES;
                break;
            }
        }
        if (!sticky.selected) {
            but.highlighted = touched;
            if (touched) {
                // When sticky is turned back on, we want this button to be in the FIFO.
                [stickyFIFO removeObject:but];
                [stickyFIFO addObject:but];
            }
        } else if (touched) {
            but.highlighted = !but.highlighted;
            [stickyFIFO removeObject:but];
            if (but.highlighted) {
                [stickyFIFO addObject:but];
                while ([stickyFIFO count] > self.maxColors) {
                    TCColorButton* removing = stickyFIFO[0];
                    //NSLog(@"sticky fifo too big; removing button with dmx %d", removing.dmx);
                    removing.highlighted = NO;
                    [stickyFIFO removeObject:removing];
                    [dmxOutputs removeObject:@(removing.dmx)];
                }
            }
        }
        // Now make sure this isn't too many colors.
        if (but.highlighted) {
            if (!sticky.selected && [dmxOutputs count] >= self.maxColors) {
                but.highlighted = NO;
            } else {
                [dmxOutputs addObject:color[2]];
            }
        }
    }
    //NSLog(@"outputs for %d touches %@", [touches count], dmxOutputs);
    if (![dmxOutputs count]) {
        // If user untouched everything, make it a blackout (I think?)
        [dmxOutputs addObject:@0];
    }
    [self.delegate pocketColorDMXChanged:dmxOutputs from:self];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Rest of init in awakeFromNib
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
