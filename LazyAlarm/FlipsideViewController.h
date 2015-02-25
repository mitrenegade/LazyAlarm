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
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withAlarm:(NSDate*)alarm;
@end

@interface FlipsideViewController : UIViewController <UIPickerViewDelegate>
{
    IBOutlet UILabel *labelAlarmState;
    IBOutlet UISegmentedControl * selector;
    IBOutlet UIDatePicker * timePicker;
    IBOutlet UISwitch * lazyOnOff;
    IBOutlet UINavigationItem * navItem;
}
@property (weak, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic) BOOL isEditingLazyAlarm;
@property (nonatomic) NSDate *currentAlarm;

- (IBAction)done:(id)sender;
- (IBAction)didSwitchAlarm:(id)sender;
- (IBAction)didToggleLazyAlarm:(id)sender;
@end
