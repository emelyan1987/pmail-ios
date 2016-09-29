//
//  PMCalendarColourVC.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCalendar.h"

@class PMCalendarColourVC;
@protocol PMCalendarColourVCDelegate <NSObject>
- (void)PMCalendarColourVCDelegateColourDidChange:(PMCalendarColourVC*)calendarColourVC;
@end

@interface PMCalendarColourVC : UIViewController
@property(nonatomic, strong) DBCalendar *calendar;
@property(nonatomic, weak) id<PMCalendarColourVCDelegate> delegate;
@end
