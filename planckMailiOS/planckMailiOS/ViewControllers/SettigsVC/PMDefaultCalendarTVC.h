//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCalendar.h"


@class PMDefaultCalendarTVC;

@protocol PMDefaultCalendarTVCDelegate <NSObject>

-(void)defaultCalendarTVC:(PMDefaultCalendarTVC*)defaultCalendarTVC didSelectCalendar:(DBCalendar*)calendar;

@end

@interface PMDefaultCalendarTVC : UITableViewController

@property(nonatomic, strong) id<PMDefaultCalendarTVCDelegate> delegate;
@end
