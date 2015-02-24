//
//  FlipsideViewController.h
//  LazyAlarm
//
//  Created by Bobby Ren on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appirater.h"
@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withAlarms:(NSMutableDictionary*)alarms;
@end

@interface FlipsideViewController : UIViewController <UIPickerViewDelegate>
{
    IBOutlet UISegmentedControl * selector;
    IBOutlet UIDatePicker * timePicker;
    IBOutlet UISwitch * lazyOnOff;
    IBOutlet UINavigationItem * navItem;
    NSDate * normalAlarm;
    NSDate * lazyAlarm;
    BOOL bLazyIsOn;
}
@property (weak, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)didChangeTime:(id)sender;
- (IBAction)didSwitchAlarm:(id)sender;
- (IBAction)didToggleLazyAlarm:(id)sender;
-(void)checkOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
