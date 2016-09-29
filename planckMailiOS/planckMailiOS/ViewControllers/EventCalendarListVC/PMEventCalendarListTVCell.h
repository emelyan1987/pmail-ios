//
//  PMEventCalendarListTVCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/30/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCalendar.h"

@class PMEventCalendarListTVCell;



@interface PMEventCalendarListTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *markView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property DBCalendar *calendar;

-(void)configureCell:(DBCalendar*)calendar selected:(BOOL)selected;
@end
