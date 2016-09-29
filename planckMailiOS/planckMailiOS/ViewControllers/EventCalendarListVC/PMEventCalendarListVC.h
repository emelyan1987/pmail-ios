//
//  PMEventCalendarListVC.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCalendar.h"

@protocol PMEventCalendarListVCDelegate <NSObject>
-(void)didSelectCalendar:(DBCalendar*)calendar;
@end

@interface PMEventCalendarListVC : UIViewController

@property id<PMEventCalendarListVCDelegate> delegate;
@property DBCalendar* selectedCalendar;

@end
