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

    if (!TESTING) {
        [labelDebug setHidden:YES];
    }
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
}

#pragma mark defaults
-(void)alarmFromDefaults {
    NSNumber *hour, *minute;
    hour = [_defaults objectForKey:kKeyLazyAlarmHour];
    minute = [_defaults objectForKey:kKeyLazyAlarmMinute];
    if (hour && minute) {
        NSDate * now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
        [comps setHour:[hour intValue]];
        [comps setMinute:[minute intValue]];
        [comps setSecond:0];
        lazyAlarm = [cal dateFromComponents:comps];
        if ([lazyAlarm timeIntervalSinceNow] < 0)
            lazyAlarm = [normalAlarm dateByAddingTimeInterval:24*3600];
    }

    hour = [_defaults objectForKey:kKeyNormalAlarmHour];
    minute = [_defaults objectForKey:kKeyNormalAlarmMinute];
    if (hour && minute) {
        NSDate * now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
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
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];

    NSString *details = @"Alarm details: \n";
    if (lazyAlarm) {
        NSString *dateString = [dateFormatter stringFromDate:lazyAlarm];
        details = [NSString stringWithFormat:@"%@Lazy alarm: %@\n", details, dateString];
    }
    if (normalAlarm) {
        NSString *dateString = [dateFormatter stringFromDate:normalAlarm];
        details = [NSString stringWithFormat:@"%@Normal alarm: %@\n", details, dateString];
    }

    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *n in notifications) {
        NSDate *date = n.fireDate;
        NSString *dateString = [dateFormatter stringFromDate:date];
        details = [NSString stringWithFormat:@"%@Scheduled notification: %@\n", details, dateString];
    }
    labelDebug.text = details;
#endif
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withAlarm:(NSDate *)alarm
{
    [self dismissViewControllerAnimated:YES completion:nil];

    NSDate * now = alarm;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    NSInteger hour = comps.hour;
    NSInteger min = comps.minute;
    if (bIsLazy) {
        lazyAlarm = alarm;
        [_defaults setObject:@(hour) forKey:kKeyLazyAlarmHour];
        [_defaults setObject:@(min) forKey:kKeyLazyAlarmMinute];
    }
    else {
        normalAlarm = alarm;
        [_defaults setObject:@(hour) forKey:kKeyNormalAlarmHour];
        [_defaults setObject:@(min) forKey:kKeyNormalAlarmMinute];
    }

    // set alarm, and redisplay message
    [self setSwitchToLazy:bIsLazy];
    [self setAlarmAtDate:alarm];

    [self showAllNotifications];
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

    [self updateDebugDetails];
}

-(IBAction)didClickSwitch:(id)sender {
    bIsLazy = !bIsLazy;
    [[NSUserDefaults standardUserDefaults] setObject:@(bIsLazy) forKey:kKeyAlarmMode];

    [self setSwitchToLazy:bIsLazy];
    [self showAllNotifications];
    NSLog(@"DidClickSwitch! value now %d", bIsLazy);
}

-(void)setSwitchToLazy:(BOOL)lazy {
    NSLog(@"Calling setSwitchToLazy: %d", lazy);
    if (lazy) {
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_on.png"] forState:UIControlStateNormal];
        if (lazyAlarm) {
            [detailLabel setText: ConfiguredAttributeWithDefaultValue(@"LazyAlarmSetMessage", nil, nil,@"You are being lazy and sleeping in", @"Lazy alarm set message")];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"LazyAlarmNotSetMessage", nil, nil,@"No alarm currently set for sleeping in!", @"Lazy alarm not set message")];
        }
    }
    else {
        [lazySwitch setBackgroundImage:[UIImage imageNamed:@"014_switch_off.png"] forState:UIControlStateNormal];
        if (normalAlarm) {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmSetMessage", nil, nil,@"You are being punctual and getting up bright and early!", @"Nonlazy alarm set message")];
        }
        else {
            [detailLabel setText:ConfiguredAttributeWithDefaultValue(@"NonlazyAlarmNotSetMessage", nil, nil,@"No alarm currently set!", @"Nonlazy alarm not set message")];
        }
    }
    [self setAlarmAtDate:bIsLazy?lazyAlarm:normalAlarm];
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
