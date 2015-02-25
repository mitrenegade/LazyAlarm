//
//  AppDelegate.m
//  LazyAlarm
//
//  Created by Bobby Ren on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MainViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Appirater.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // call the Appirater class
    [Appirater appLaunched];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    [Fabric with:@[CrashlyticsKit]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Alarm" message:@"Time to get up!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
    // BUZZ
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // PLAY AUDIO
    SystemSoundID audioEffect;
    NSString *path  = [[NSBundle mainBundle] pathForResource : @"alarm" ofType :@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else
    {
        NSLog(@"error, file not found: %@", path);
    }
    // display info
    NSDictionary * userInfo = [notification userInfo];
    NSString * alarmType = [userInfo objectForKey:@"alarmType"];
    NSString * alarmTime = [userInfo objectForKey:@"alarmTime"];
    NSLog(@"Alarm! Type %@ time %@", alarmType, alarmTime);
    
    // reset alarms
    [self.mainViewController autoUpdateAlarm:alarmType];
}

@end
