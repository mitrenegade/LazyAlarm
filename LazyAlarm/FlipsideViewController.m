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
    BOOL alarmState; // not being used yet
    if (self.isEditingLazyAlarm) {
        alarmState = [_defaults boolForKey:kKeyLazyAlarmEnabled];
    }
    else {
        alarmState = [_defaults boolForKey:kKeyNormalAlarmEnabled];
    }

    timePicker.datePickerMode = UIDatePickerModeTime;
    if (self.currentAlarm) {
        timePicker.date = self.currentAlarm;
    }
    else {
        timePicker.date = [NSDate date];
    }

    [self updateAlarmTitle];
}

-(void)updateAlarmTitle {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [Appirater userDidSignificantEvent:YES];
    NSDate *currentAlarm = timePicker.date;
    NSString *dateString = [dateFormatter stringFromDate:currentAlarm];
    if (!self.isEditingLazyAlarm) {
        [labelAlarmState setText:(currentAlarm?[NSString stringWithFormat:@"Regular alarm set before: %@", dateString]:@"Not set")];
    }
    else {
        [labelAlarmState setText:(currentAlarm?[NSString stringWithFormat:@"Lazy alarm set after: %@", dateString]:@"Not set")];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [Appirater userDidSignificantEvent:YES];
    [self.delegate flipsideViewControllerDidFinish:self withAlarm:timePicker.date];
}

@end
