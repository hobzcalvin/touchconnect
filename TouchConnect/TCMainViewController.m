//
//  TCMainViewController.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCMainViewController.h"
#import "TCButton.h"

#define NUM_SCANS 7
#define SCAN_NOTE_START 6
#define SCAN_PACKET_LEN 8

#define NUM_PARS 2
#define PAR_NOTE_START (SCAN_NOTE_START + SCAN_PACKET_LEN * NUM_SCANS)
#define PAR_PACKET_LEN 8

#define NUM_FX 1
#define FX_NOTE_START (PAR_NOTE_START + PAR_PACKET_LEN * NUM_PARS)
#define FX_PACKET_LEN 4

#define LASER_CC_START 0
#define SCAN_FUNC_START 8

@interface TCMainViewController ()

@end

@implementation TCMainViewController {
    __weak IBOutlet TCHueSatPicker *hueView;
    __weak IBOutlet TCButton *parModeButton;
    __weak IBOutlet TCTouchView *touchView;
    __weak IBOutlet TCButton *scanModeButton;
    __weak IBOutlet UILabel *waitingLabel;
    __weak IBOutlet TCButton *mirrorPanButton;
    __weak IBOutlet TCButton *mirrorTiltButton;
    __weak IBOutlet TCPocketColorPicker *pocketColorPicker;
    __weak IBOutlet TCButton *laserButton;
    __weak IBOutlet TCSlider *scanStrobeSlider;
    __weak IBOutlet TCSlider *parStrobeSlider;
    __weak IBOutlet TCSlider *fxStrobeSlider;
    __weak IBOutlet TCSlider *parBrightSlider;
    __weak IBOutlet TCSlider *fxSpeedSlider;
    __weak IBOutlet TCPocketColorPicker *fxColorPicker;
    
    boolean_t forScan;
}

@synthesize server = _server;


- (void)viewDidLoad
{
    [super viewDidLoad];
    hueView.delegate = self;
    hueView.maxTouches = NUM_PARS;
    
    touchView.delegate = self;
    touchView.maxTouches = NUM_SCANS;
    
    pocketColorPicker.delegate = self;
    pocketColorPicker.maxColors = NUM_SCANS;
    
    [laserButton addTarget:self action:@selector(buttonToggled:) forControlEvents:UIControlEventTouchUpInside];
    
    scanStrobeSlider.delegate = self;
    parStrobeSlider.delegate = self;
    fxStrobeSlider.delegate = self;
    
    parBrightSlider.delegate = self;
    
    fxSpeedSlider.delegate = self;
    fxColorPicker.delegate = self;
    fxColorPicker.maxColors = NUM_FX;

    [parModeButton addTarget:self action:@selector(buttonToggled:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sliderValueChanged:(float)value from:(TCSlider*)sender {
    if (sender == scanStrobeSlider) {
        for (int i = 0; i < NUM_SCANS; i++) {
            Byte raw[] = {
                // Lower bound = 17; upper 240-255. But all that is halved here.
                0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 4, 9 + 110.5 * (value / sender.topLine),
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }
    } else if (sender == parStrobeSlider) {
        // Here a low value (< 16) is strobe-off; everything else is speed.
        Byte val = value >= sender.topLine ? 0 : 8 + 119 * (value / sender.topLine);
        for (int i = 0; i < NUM_PARS; i++) {
            Byte raw[] = {
                0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 4, val,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];            
        }
    } else if (sender == fxStrobeSlider) {
        // Here a zero value is strobe-off; everything else is speed.
        Byte val = value >= sender.topLine ? 0 : 1 + 126.5 * (value / sender.topLine);
        for (int i = 0; i < NUM_FX; i++) {
            Byte raw[] = {
                0x90, FX_NOTE_START + i * FX_PACKET_LEN + 2, val,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }        
    } else if (sender == parBrightSlider) {
        for (int i = 0; i < NUM_PARS; i++) {
            Byte raw[] = {
                0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 6, 127 * value,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }        
    } else if (sender == fxSpeedSlider) {
        for (int i = 0; i < NUM_FX; i++) {
            Byte raw[] = {
                0x90, FX_NOTE_START + i * FX_PACKET_LEN + 1, 5 + 117 * value,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }        
    }
}

-(void)buttonToggled:(UIButton*)but {
    if (but == laserButton) {
        Byte raw[] = {
            0xB0, LASER_CC_START + (laserButton.selected ? 1 : 0), 64
        };
        [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        
    } else if (but == parModeButton) {
        
    }
}

- (void)connectionComplete:(Server*)theServer {
    _server = theServer;
    waitingLabel.hidden = YES;
}

- (void)connectionLost {
    waitingLabel.hidden = NO;
}

- (void)pocketColorDMXChanged:(NSArray*)dmxOutputs from:(TCPocketColorPicker *)sender {
    if (sender == pocketColorPicker) {
        for (int i = 0; i < NUM_SCANS; i++) {
            Byte raw[] = {
                // Divide by 2: Midi resolution loss.
                0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 2, [dmxOutputs[i % [dmxOutputs count]] intValue] / 2,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }
    } else if (sender == fxColorPicker) {
        for (int i = 0; i < NUM_FX; i++) {
            Byte raw[] = {
                // Divide by 2: Midi resolution loss.
                0x90, FX_NOTE_START + i * FX_PACKET_LEN + 0, [dmxOutputs[i % [dmxOutputs count]] intValue] / 2,
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }
    }
}

- (void)hueSatColorsChanged:(NSArray*)colors {
    if (!waitingLabel.hidden) {
        return;
    }
    if (![colors count]) {
        return;
    }
    CGFloat r,g,b;
    UIColor* color;
    for (int i = 0; i < NUM_PARS; i++) {
        color = colors[i % [colors count]];
        [color getRed:&r green:&g blue:&b alpha:NULL];
        Byte raw[] = {
            0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 0, r * 127,
            0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 1, g * 127,
            0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 2, b * 127
        };
        [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
    }
}

- (void)changesStarted {
    parModeButton.selected = NO;
    for (int i = 0; i < NUM_PARS; i++) {
        Byte raw[] = {
            0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 5, 0,
        };
        [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
    }    
}

- (void)placementStarted {
    scanModeButton.selected = NO;
    for (int i = 0; i < NUM_SCANS; i++) {
        Byte raw[] = {
            0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 5, 127,
        };
        [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
    }    
}

- (void)positionsChanged:(NSArray*)positions {
    if (!waitingLabel.hidden) {
        return;
    }
    if (![positions count]) {
        return;
    }
    for (int i = 0; i < NUM_SCANS; i++) {
        CGPoint point = [positions[i % [positions count]] CGPointValue];
        if (mirrorPanButton.selected && (i / [positions count]) % 2) {
            point.x = 1 - point.x;
        }
        if (mirrorTiltButton.selected && (i / [positions count]) % 2) {
            point.y = 1 - point.y;
        }
        Byte raw[] = {
            0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 0, point.x * 127,
            0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 1, point.y * 127,
            // Double-density settings for full resolution.
            // XXX: Sadly, QLC can't handle this double-resolution input from MIDI. Guess I should write my own plugin and not use MIDI...
            //0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 2 + (point.x < 0.5 ? 0 : 1), (point.x < 0.5 ? point.x * 256 : (point.x - 0.5) * 127),
            //0x90, SCAN_NOTE_START + i * SCAN_PACKET_LEN + 4 + (point.y < 0.5 ? 0 : 1), (point.y < 0.5 ? point.y * 256 : (point.y - 0.5) * 127),
        };
        NSData* data = [NSData dataWithBytes:raw length:sizeof(raw)];
        //NSLog(@"sending data %@", [data description]);
        [_server sendData:data error:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(TCFlipsideViewController *)controller withResult:(id)result
{
    if (controller.forScan) {
        scanModeButton.selected = result != nil;
        [touchView setShade:result != nil];
        if (result) {
            Byte raw[] = {
                0xB0, SCAN_FUNC_START + [result intValue], 64
            };
            [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
        }
    } else {
        parModeButton.selected = result != nil;
        [hueView setShade:result != nil];
        if (result) {
            for (int i = 0; i < NUM_PARS; i++) {
                Byte raw[] = {
                    0x90, PAR_NOTE_START + i * PAR_PACKET_LEN + 5, [result intValue],
                };
                [_server sendData:[NSData dataWithBytes:raw length:sizeof(raw)] error:NULL];
            }
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    (forScan ? scanModeButton : parModeButton).selected = NO;
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        forScan = NO;
        parModeButton.selected = YES;
        
        [[segue destinationViewController] setDelegate:self];
        TCFlipsideViewController* flip = [segue destinationViewController];
        flip.forScan = NO;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }

    if ([[segue identifier] isEqualToString:@"showScanModes"]) {
        forScan = YES;
        scanModeButton.selected = YES;
        
        [[segue destinationViewController] setDelegate:self];
        TCFlipsideViewController* flip = [segue destinationViewController];
        flip.forScan = YES;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }

}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)viewDidUnload {
    [self setMainView:nil];
    waitingLabel = nil;
    touchView = nil;
    hueView = nil;
    mirrorPanButton = nil;
    mirrorTiltButton = nil;
    pocketColorPicker = nil;
    laserButton = nil;
    scanStrobeSlider = nil;
    parStrobeSlider = nil;
    fxStrobeSlider = nil;
    parBrightSlider = nil;
    fxSpeedSlider = nil;
    fxColorPicker = nil;
    parModeButton = nil;
    scanModeButton = nil;
    [super viewDidUnload];
}
@end
