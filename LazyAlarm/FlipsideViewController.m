//
//  FlipsideViewController.m
//  LazyAlarm
//
//  Created by Bobby Ren on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    normalAlarm = nil;
    lazyAlarm = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    bLazyIsOn = [lazyOnOff isOn];
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    int alarmIndex = selector.selectedSegmentIndex;
    if (alarmIndex == 0) {
        [navItem setTitle:@"Set regular alarm"];
        if (!normalAlarm)
            normalAlarm = timePicker.date;
        else
            [timePicker setDate:normalAlarm];
        [lazyOnOff setHidden:YES];
    }
    else if (alarmIndex == 1) {
        [navItem setTitle:@"Set lazy alarm"];
        if (!lazyAlarm) 
            lazyAlarm = timePicker.date;
        else 
            [timePicker setDate:lazyAlarm];
        [lazyOnOff setHidden:NO];
    }
}

-(void)checkOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        [selector setFrame:CGRectMake(137, 48, 207, 30)];
        [timePicker setFrame:CGRectMake(112, 85, 256, 216)];
        [lazyOnOff setFrame:CGRectMake(386, 50, 79, 27)];
    }
    else {
        [selector setFrame:CGRectMake(57, 73, 207, 30)];
        [timePicker setFrame:CGRectMake(0, 179, 320, 216)];
        [lazyOnOff setFrame:CGRectMake(121, 122, 79, 27)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    [self checkOrientation:interfaceOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    NSMutableDictionary * alarmList = [[NSMutableDictionary alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:SS"];
    [Appirater userDidSignificantEvent:YES];
    if (normalAlarm) {
        NSString *dateString = [dateFormatter stringFromDate:normalAlarm];
        NSLog(@"Normal alarm set to %@", dateString);
        [alarmList setObject:normalAlarm forKey:@"normal"];
    }
    if (lazyAlarm) {
        if (bLazyIsOn) {
            NSString *dateString = [dateFormatter stringFromDate:lazyAlarm];
            NSLog(@"Lazy alarm set to %@", dateString);
            [alarmList setObject:lazyAlarm forKey:@"lazy"];
        }
        else {
            NSLog(@"Lazy alarm set to off!");
        }
    }
          
    [self.delegate flipsideViewControllerDidFinish:self withAlarms:alarmList];
}

-(IBAction)didChangeTime:(id)sender {
    int alarmIndex = selector.selectedSegmentIndex;
    if (alarmIndex == 0)
        normalAlarm = [timePicker.date copy];
    else if (alarmIndex == 1)
        lazyAlarm = [timePicker.date copy];
}

-(IBAction)didSwitchAlarm:(id)sender {
    int alarmIndex = selector.selectedSegmentIndex;
    NSLog(@"Did switch alarm to index %d", alarmIndex);
    if (alarmIndex == 0) {
        [navItem setTitle:@"Set regular alarm"];
//        [Flurry logEvent:@"DidChangeRegularAlarmTime"];
        if (normalAlarm)
            [timePicker setDate:normalAlarm];
        else {
            [timePicker setDate:[NSDate date]];
            normalAlarm = timePicker.date;
        }
        [lazyOnOff setHidden:YES];
    }
    if (alarmIndex == 1) {
        [navItem setTitle:@"Set lazy alarm"];
//        [Flurry logEvent:@"DidChangeLazyAlarmTime"];
        if (lazyAlarm)
            [timePicker setDate:lazyAlarm];
        else {
            [timePicker setDate:[NSDate date]];
            lazyAlarm = timePicker.date;
        }
        [lazyOnOff setHidden:NO];
    }
}

-(IBAction)didToggleLazyAlarm:(id)sender {
    bLazyIsOn = [lazyOnOff isOn];
    if (bLazyIsOn) {
//        [Flurry logEvent:@"DidTurnLazyBackOn"];
    }
    else {
//        [Flurry logEvent:@"DidTurnLazyOff"];
    }
}

@end
