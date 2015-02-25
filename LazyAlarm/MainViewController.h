//
//  MainViewController.h
//  LazyAlarm
//
//  Created by Bobby Ren on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "AttributeConfigurator.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>
{
    //IBOutlet UISwitch * lazySwitch;
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * detailLabel;
    IBOutlet UIButton * lazySwitch;
    IBOutlet UIButton * showInfo;

    IBOutlet UILabel *labelDebug;

    BOOL bIsLazy;
    NSDate * normalAlarm;
    NSDate * lazyAlarm;
}
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)showInfo:(id)sender;
- (IBAction)didClickSwitch:(id)sender;
-(void)checkOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)autoUpdateAlarm:(NSString*)alarmType;
@end
