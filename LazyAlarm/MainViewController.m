//
//  MainViewController.m
//  LazyAlarm
//
//  Created by Bobby Ren on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

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
    //lazySwitch.transform = CGAffineTransformMakeScale(3, 3);
    bIsLazy = NO;
    [self setSwitchToLazy:bIsLazy];    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [titleLabel setText:ConfiguredAttributeWithDefaultValue(@"LazyTitle", nil, nil, @"I want to be lazy:", @"Title text")];
     //NS_LocalizedStringWithDefaultValue(@"LazyTitle", @"Localizable", [NSBundle mainBundle], @"DEFAULT: I want to be lazy:", @"Title text")];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [Flurry logPageView];
}

/*
-(void)checkOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // check orientation
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation      
        [titleLabel setFrame:CGRectMake(80, 60, 205, 70)];
        [lazySwitch setFrame:CGRectMake(330, 50, 105, 140)];
//        [amILazy setFrame:CGRectMake(80, 140, 205, 70)];
        [lazyLabel setFrame:CGRectMake(108, 218, 265, 60)];
        [showInfo setFrame:CGRectMake(442, 261, 18, 19)];
//        [Flurry logEvent:@"OrientationChangeLandscape"];
    }
    else {
        [titleLabel setFrame:CGRectMake(8, 68, 205, 70)];
        [lazySwitch setFrame:CGRectMake(108, 171, 105, 140)];
//        [amILazy setFrame:CGRectMake(179, 54, 141, 98)];
        [lazyLabel setFrame:CGRectMake(28, 333, 265, 60)];
        [showInfo setFrame:CGRectMake(282, 421, 18, 19)];
//        [Flurry logEvent:@"OrientationChangePortrait"];
    }
}
*/
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

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withAlarms:(NSMutableDictionary *)alarms
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }

    NSDate * normal = [alarms objectForKey:@"normal"];
    NSDate * lazy = [alarms objectForKey:@"lazy"];
    normalAlarm = [[alarms objectForKey:@"normal"] copy];
    lazyAlarm = [[alarms objectForKey:@"lazy"] copy];
    
    // set alarm, and redisplay message
    [self setSwitchToLazy:bIsLazy];
    /*
    NSDate * alarmDate = normalAlarm;
    if (bIsLazy)
        alarmDate = lazyAlarm;
    [self setAlarmAtDate:alarmDate];
     */
    /*
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:SS"];
    NSString *dateString = [dateFormatter stringFromDate:normalAlarm];
    NSLog(@"FlipSide finished: Normal alarm set to %@", dateString);
    NSString *dateString2 = [dateFormatter stringFromDate:lazyAlarm];
    NSLog(@"FlipSide finished: Lazy alarm set to %@", dateString);
    */
    [self doSetAlarm:nil];
    
    [self showAllNotifications];
}

- (IBAction)showInfo:(id)sender
{
//    [Flurry logEvent:@"ClickShowInfoButton"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

-(void)setAlarmAtDate:(NSDate*)date {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *notif1 = [[UILocalNotification alloc] init];
    if ([date compare:[NSDate date]] == NSOrderedAscending) {
        date = [NSDate dateWithTimeInterval:3600*24 sinceDate:date];
    }
    notif1.fireDate = date;
    //notif1.soundName = UILocalNotificationDefaultSoundName;
    notif1.alertBody = @"Alarm";
    if (notif1.fireDate) {
        NSString * isLazy = @"Normal Alarm";
        if (bIsLazy)
            isLazy = @"Lazy Alarm";
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
        NSString *dateString = [dateFormatter stringFromDate:notif1.fireDate];
        NSLog(@"Alarm time now set to %@, type %@", dateString, isLazy);
        //[[UIApplication sharedApplication] presentLocalNotificationNow:notif1];
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:isLazy, @"alarmType", dateString, @"alarmTime", nil];
        [notif1 setUserInfo:userInfo];
        [[UIApplication sharedApplication] scheduleLocalNotification:notif1];    
    }
    else {
        NSLog(@"No alarm time set: all alarms cancelled.");
    }
}

-(IBAction)didClickSwitch:(id)sender {
    [self toggleSwitch];
    NSLog(@"DidClickSwitch! value now %d", bIsLazy);
    /*
    NSDate * alarmDate = normalAlarm;
    if (bIsLazy)
        alarmDate = lazyAlarm;
    [self setAlarmAtDate:alarmDate];
     */
}

-(void)setSwitchToLazy:(BOOL)lazy {
    NSLog(@"Calling setSwitchToLazy: %d", lazy);
    if (lazy) {
//        [Flurry logEvent:@"DidSwitchToLazy"];
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_on.png"] forState:UIControlStateNormal];
//        [amILazy setText:ConfiguredAttributeWithDefaultValue(@"YesLabel", nil, nil, @"YES", @"Affirmative statement")];
         //NS_LocalizedStringWithDefaultValue(@"YesLabel", nil, [NSBundle mainBundle], @"DEFAULT: YES", @"Affirmative statement")];
        if (lazyAlarm) {
            [detailLabel setText: ConfiguredAttributeWithDefaultValue(@"LazyAlarmSetMessage", nil, nil,@"You are being lazy and sleeping in", @"Lazy alarm set message")];
            //NS_LocalizedStringWithDefaultValue(@"LazyAlarmSetMessage", nil, [NSBundle mainBundle], @"DEFAULT: You are being lazy and sleeping in!", @"Lazy alarm set message")];
//            [self setAlarmAtDate:lazyAlarm];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"LazyAlarmNotSetMessage", nil, nil,@"No alarm currently set for sleeping in!", @"Lazy alarm not set message")];
             //NS_LocalizedStringWithDefaultValue(@"LazyAlarmNotSetMessage", nil, [NSBundle mainBundle], @"DEFAULT: No alarm currently set for sleeping in!", @"Lazy alarm not set message")];
//            [self setAlarmAtDate:nil];
        }
    }
    else {
//        [Flurry logEvent:@"DidSwitchToNotLazy"];
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_off.png"] forState:UIControlStateNormal];
//        [amILazy setText:ConfiguredAttributeWithDefaultValue(@"NoLabel",nil, nil, @"NO", @"Negatory statement")];
         //NS_LocalizedStringWithDefaultValue(@"NoLabel", nil, [NSBundle mainBundle], @"DEFAULT: NO", @"Negatory statement")];
        if (normalAlarm) {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmSetMessage", nil, nil,@"You are being punctual and getting up bright and early!", @"Nonlazy alarm set message")];
             //NS_LocalizedStringWithDefaultValue(@"NonlazyAlarmSetMessage", nil, [NSBundle mainBundle], @"DEFAULT: You are being punctual and getting up bright and early!", @"Nonlazy alarm set message")];
//            [self setAlarmAtDate:normalAlarm];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmNotSetMessage", nil, nil,@"No alarm currently set!", @"Nonlazy alarm not set message")];
             //NS_LocalizedStringWithDefaultValue(@"NonlazyAlarmNotSetMessage", nil, [NSBundle mainBundle], @"DEFAULT: No alarm currently set!", @"Nonlazy alarm not set message")];
//            [self setAlarmAtDate:nil];
        }
    }
    [self doSetAlarm:nil];
}
-(void)toggleSwitch {
    bIsLazy = !bIsLazy;
    [self setSwitchToLazy:bIsLazy];
    [self showAllNotifications];
}

-(void)showAllNotifications {
    NSArray * notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"ShowAllNotifications showing %d notifications", [notificationsArray count]);
    int ct = 0;
    for (UILocalNotification * not in notificationsArray) {
        // display info
        NSDictionary * userInfo = [not userInfo];
        NSString * alarmType = [userInfo objectForKey:@"alarmType"];
        NSString * alarmTime = [userInfo objectForKey:@"alarmTime"];
        NSLog(@"Notification %d: Type %@ time %@", ct, alarmType, alarmTime);
        ct++;
    }
}

-(IBAction)doSetAlarm:(id)sender {
    NSLog(@"***Did click set alarm!***");
    NSDate * alarmDate = normalAlarm;
    if (bIsLazy)
        alarmDate = lazyAlarm;
    [self setAlarmAtDate:alarmDate];
}

-(void)autoUpdateAlarm:(NSString *)alarmType {
    if ([alarmType isEqualToString:@"Normal Alarm"]) {
        [self setAlarmAtDate:normalAlarm];
    }
    else {
        [self setAlarmAtDate:lazyAlarm];
    }
}


@end
