//
//  PMCalendarListTVCell.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCalendar.h"


@class PMCalendarListTVCell;
@protocol PMCalendarListTVCellDelegate <NSObject>
- (void)PMCalendarListTVCellColorBtnDidPress:(PMCalendarListTVCell*)cell calendar:(DBCalendar*)calendar;
- (void)PMCalendarListTVCell:(PMCalendarListTVCell*)cell selectedState:(BOOL)state;
@end

@interface PMCalendarListTVCell : UITableViewCell
- (void)configureCell:(DBCalendar*)calendar;
- (void)changeSelectedState;
@property(nonatomic, weak) id<PMCalendarListTVCellDelegate> delegate;
@end
