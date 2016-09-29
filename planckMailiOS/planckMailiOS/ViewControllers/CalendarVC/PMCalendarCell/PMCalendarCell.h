//
//  PMCalendarCell.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@interface PMCalendarCell : UITableViewCell
+(instancetype)newCell;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIView *calendarColorView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (void)setEvent:(PMEventModel *)event;

@end
