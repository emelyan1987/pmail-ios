//
//  PMSnoozeAlertViewController.h
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMThread.h"
@protocol PMAlertViewControllerDelegate;

@interface PMSnoozeAlertViewController : UIViewController

@property (nonatomic, weak) id<PMAlertViewControllerDelegate> delegate;

@property (nonatomic, strong) PMThread *inboxMailModel;

@property (nonatomic, assign) BOOL isNotifyMe;   // YES : Notify me, NO : Snooze
@end

@protocol PMAlertViewControllerDelegate <NSObject>

- (void)didScheduleWithDateType:(ScheduleDateType)dateType date:(NSDate*)date autoAsk:(NSInteger)autoAsk;
- (void)didCancelSchdule;
@end
