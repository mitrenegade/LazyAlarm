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
    bIsLazy = [[[NSUserDefaults standardUserDefaults] objectForKey:kKeyAlarmMode] boolValue];

    [self alarmFromDefaults];
    [self setSwitchToLazy:bIsLazy];
    [self setAlarmAtDate:bIsLazy?lazyAlarm:normalAlarm];

    if (!TESTING) {
        [labelDebug setHidden:YES];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:tap];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark defaults
-(void)alarmFromDefaults {
    NSNumber *hour, *minute;
    hour = [_defaults objectForKey:kKeyLazyAlarmHour];
    minute = [_defaults objectForKey:kKeyLazyAlarmMinute];
    if (hour && minute) {
        NSDate * now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
        [comps setHour:[hour intValue]];
        [comps setMinute:[minute intValue]];
        [comps setSecond:0];
        lazyAlarm = [cal dateFromComponents:comps];
        if ([lazyAlarm timeIntervalSinceNow] < 0)
            lazyAlarm = [lazyAlarm dateByAddingTimeInterval:24*3600];
    }

    hour = [_defaults objectForKey:kKeyNormalAlarmHour];
    minute = [_defaults objectForKey:kKeyNormalAlarmMinute];
    if (hour && minute) {
        NSDate * now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
        [comps setHour:[hour intValue]];
        [comps setMinute:[minute intValue]];
        [comps setSecond:0];
        normalAlarm = [cal dateFromComponents:comps];
        if ([normalAlarm timeIntervalSinceNow] < 0)
            normalAlarm = [normalAlarm dateByAddingTimeInterval:24*3600];
    }

    [self updateDebugDetails];
}

-(void)updateDebugDetails {
#if TESTING
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:SS"];

    NSString *details = @"Alarm details: \n";
    if (lazyAlarm) {
        NSString *dateString = [dateFormatter stringFromDate:lazyAlarm];
        details = [NSString stringWithFormat:@"%@Lazy: %@\n", details, dateString];
    }
    if (normalAlarm) {
        NSString *dateString = [dateFormatter stringFromDate:normalAlarm];
        details = [NSString stringWithFormat:@"%@Normal: %@\n", details, dateString];
    }

    NSDateFormatter* dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *n in notifications) {
        NSDate *date = n.fireDate;
        NSString *dateString = [dateFormatter2 stringFromDate:date];
        details = [NSString stringWithFormat:@"%@Scheduled notification: %@\n", details, dateString];
    }
    labelDebug.text = details;
#endif
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withAlarm:(NSDate *)alarm options:(AlarmOptions)options
{
    [self dismissViewControllerAnimated:YES completion:nil];

    NSDate * now = alarm;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
    NSInteger hour = comps.hour;
    NSInteger min = comps.minute;
    if (bIsLazy) {
        lazyAlarm = alarm;
        [_defaults setObject:@(hour) forKey:kKeyLazyAlarmHour];
        [_defaults setObject:@(min) forKey:kKeyLazyAlarmMinute];
        [_defaults setObject:@(options) forKey:kKeyLazyAlarmOptions];
    }
    else {
        normalAlarm = alarm;
        [_defaults setObject:@(hour) forKey:kKeyNormalAlarmHour];
        [_defaults setObject:@(min) forKey:kKeyNormalAlarmMinute];
        [_defaults setObject:@(options) forKey:kKeyNormalAlarmOptions];
    }

    // set alarm, and redisplay message
    [self setSwitchToLazy:bIsLazy];
    [self setAlarmAtDate:alarm];

    [self showAllNotifications];
}

-(void)setAlarmAtDate:(NSDate*)date {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    AlarmOptions options = [[_defaults objectForKey:bIsLazy?kKeyLazyAlarmOptions:kKeyNormalAlarmOptions] intValue];
    if (options == AlarmOptionsOff) {
        [self updateDebugDetails];
        return;
    }
    int minutes = 0;
    if (options == AlarmOptionsSmall) {
        minutes = arc4random()%15;
    }
    else if (options == AlarmOptionsLarge) {
        minutes = arc4random()%60;
    }

    UILocalNotification *notif1 = [[UILocalNotification alloc] init];
    if ([date timeIntervalSinceNow] <= 0) {
        date = [NSDate dateWithTimeInterval:3600*24 sinceDate:date];
    }

    if (bIsLazy) {
        // set random time after lazy date, but after now
        date = [date dateByAddingTimeInterval:minutes*60];
    }
    else {
        // set random time before normal alarm, but after now
        NSDate *newDate = [date dateByAddingTimeInterval:-minutes*60];
        if ([newDate timeIntervalSinceNow] > 0)
            date = newDate;
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

    [self updateDebugDetails];
}

-(IBAction)didClickSwitch:(id)sender {
    bIsLazy = !bIsLazy;
    [[NSUserDefaults standardUserDefaults] setObject:@(bIsLazy) forKey:kKeyAlarmMode];

    [PFAnalytics trackEventInBackground:@"alarm_switched" dimensions:@{@"mode":bIsLazy?@"Lazy":@"Normal"} block:nil];

    [self setSwitchToLazy:bIsLazy];
    [self setAlarmAtDate:bIsLazy?lazyAlarm:normalAlarm];
    [self showAllNotifications];
    NSLog(@"DidClickSwitch! value now %d", bIsLazy);
}

-(void)setSwitchToLazy:(BOOL)lazy {
    [titleLabel setText:@"Do I want to sleep in?"];
    //[titleLabel setText:@"I want to wake up on time"];

    NSLog(@"Calling setSwitchToLazy: %d", lazy);
    if (lazy) {
        AlarmOptions options = [[_defaults objectForKey:kKeyLazyAlarmOptions] intValue];
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_on.png"] forState:UIControlStateNormal];
        if (lazyAlarm && options != AlarmOptionsOff) {
            [detailLabel setText: ConfiguredAttributeWithDefaultValue(@"LazyAlarmSetMessage", nil, nil,@"Yes! You are being lazy and sleeping in", @"Lazy alarm set message")];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"LazyAlarmNotSetMessage", nil, nil,@"No alarm currently set for sleeping in!", @"Lazy alarm not set message")];
        }
    }
    else {
        AlarmOptions options = [[_defaults objectForKey:kKeyNormalAlarmOptions] intValue];
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_off.png"] forState:UIControlStateNormal];
        if (normalAlarm && options != AlarmOptionsOff) {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmSetMessage", nil, nil,@"You are being punctual and getting up bright and early!", @"Nonlazy alarm set message")];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmNotSetMessage", nil, nil,@"No alarm currently set!", @"Nonlazy alarm not set message")];
        }
    }
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

-(void)autoUpdateAlarm:(NSString *)alarmType {
    if ([alarmType isEqualToString:@"Normal Alarm"]) {
        [self setAlarmAtDate:normalAlarm];
    }
    else {
        [self setAlarmAtDate:lazyAlarm];
    }
}

-(IBAction)didClickInfo:(id)sender {
    // only log it
    [PFAnalytics trackEventInBackground:@"flip_segue" dimensions:@{@"source":@"info button"} block:nil];
}

-(void)handleGesture:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.view];
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]] && CGRectContainsPoint(detailLabel.frame, point) && gesture.state == UIGestureRecognizerStateEnded) {
        [PFAnalytics trackEventInBackground:@"flip_segue" dimensions:@{@"source":@"tap on label"} block:nil];
        [self performSegueWithIdentifier:@"FlipSegue" sender:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FlipSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        FlipsideViewController *controller = nav.viewControllers[0];
        controller.delegate = self;
        controller.isEditingLazyAlarm = bIsLazy;
        controller.currentAlarm = bIsLazy?lazyAlarm:normalAlarm;
    }
}
@end
