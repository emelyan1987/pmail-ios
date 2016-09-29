//
//  PMCalendarListVC.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMCalendarListVCDelegate <NSObject>
-(void)didDoneSelectCalendar;
-(void)didSelectCalendar;
@end

@interface PMCalendarListVC : UIViewController
@property(strong, nonatomic) id<PMCalendarListVCDelegate> delegate;
@end
