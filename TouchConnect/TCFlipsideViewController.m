//
//  TCFlipsideViewController.m
//  TouchConnect
//
//  Created by Grant Patterson on 12/19/12.
//  Copyright (c) 2012 Grant Patterson. All rights reserved.
//

#import "TCFlipsideViewController.h"

@interface TCFlipsideViewController ()

@end

@implementation TCFlipsideViewController {
    __weak IBOutlet UITableView *functionTableView;
    NSArray* parFunctions;
    NSArray* scanFunctions;
}

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    parFunctions = @[
    @[@"Color Dreaming 1", @128],
    @[@"Color Dreaming 2", @136],
    @[@"Color Dreaming 3", @144],
    @[@"Color Dreaming 4", @152],
    @[@"Color Dreaming 5", @160],
    @[@"Color Dreaming 6", @168],
    @[@"Color Dreaming 7", @176],
    @[@"Color Dreaming 8", @184],
    @[@"Color Change 1", @192],
    @[@"Color Change 2", @200],
    @[@"Color Change 3", @208],
    @[@"Color Change 4", @216],
    @[@"Color Change 5", @224],
    @[@"Color Change 6", @232],
    @[@"Sound Active 1", @240],
    @[@"Sound Active 2", @248],
    ];
	
    scanFunctions = @[
    @[@"Thingy", @0],
    @[@"Doohick", @1]
    ];
	
    functionTableView.delegate = self;
    functionTableView.dataSource = self;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.forScan ? [scanFunctions count] : [parFunctions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Function Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Function Cell"];
    }
    cell.textLabel.text = (self.forScan ? scanFunctions : parFunctions)[indexPath.row][0];
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    //[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
    
    //UITableViewCell* cell = [theTableView cellForRowAtIndexPath:newIndexPath];
    
    [self.delegate flipsideViewControllerDidFinish:self withResult:(self.forScan ? scanFunctions : parFunctions)[newIndexPath.row][1]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self withResult:nil];
}

- (void)viewDidUnload {
    functionTableView = nil;
    [super viewDidUnload];
}
@end
