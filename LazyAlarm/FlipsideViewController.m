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

    timePicker.datePickerMode = UIDatePickerModeTime;
    if (self.currentAlarm) {
        timePicker.date = self.currentAlarm;
    }
    else {
        timePicker.date = [NSDate date];
    }

    options = [[_defaults objectForKey:self.isEditingLazyAlarm?kKeyLazyAlarmOptions:kKeyNormalAlarmOptions] intValue];
    sliderOptions.value = options;

    [self updateAlarmTitle];
    [self updateSliderTitle];
}

-(void)updateAlarmTitle {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *currentAlarm = timePicker.date;
    NSString *dateString = [dateFormatter stringFromDate:currentAlarm];
    if (!self.isEditingLazyAlarm) {
        [labelAlarmState setText:(currentAlarm?[NSString stringWithFormat:@"Regular alarm set before: %@", dateString]:@"Not set")];
    }
    else {
        [labelAlarmState setText:(currentAlarm?[NSString stringWithFormat:@"Lazy alarm set after: %@", dateString]:@"Not set")];
    }
}

-(void)updateSliderTitle {
    if (self.isEditingLazyAlarm) {
        if (sliderOptions.value < 1) {
            labelDetails.text = @"Alarm off";
            options = AlarmOptionsOff;
        }
        else if (sliderOptions.value < 2) {
            labelDetails.text = @"Wake me at exactly:";
            options = AlarmOptionsExact;
        }
        else if (sliderOptions.value < 3) {
            labelDetails.text = @"Wake me little after:";
            options = AlarmOptionsSmall;
        }
        else {
            labelDetails.text = @"Wake me way after:";
            options = AlarmOptionsLarge;
        }
    }
    else {
        if (sliderOptions.value < 1) {
            labelDetails.text = @"Alarm off";
            options = AlarmOptionsOff;
        }
        else if (sliderOptions.value < 2) {
            labelDetails.text = @"Wake me at exactly:";
            options = AlarmOptionsExact;
        }
        else if (sliderOptions.value < 3) {
            labelDetails.text = @"Wake me little before:";
            options = AlarmOptionsSmall;
        }
        else {
            labelDetails.text = @"Wake me way before:";
            options = AlarmOptionsLarge;
        }
    }
}

-(IBAction)didChangeSlider:(id)sender {
    [self updateSliderTitle];
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
    if (options != AlarmOptionsOff) {
        [Appirater userDidSignificantEvent:YES];
    }

    NSDate * now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
    NSDateComponents * picked = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:timePicker.date];
    comps.hour = picked.hour;
    comps.minute = picked.minute;
    NSDate *date = [cal dateFromComponents:comps];

    [self.delegate flipsideViewControllerDidFinish:self withAlarm:date options:options];
}

@end
