//
//  PMEventCalendarListTVCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/30/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEventCalendarListTVCell.h"
#import "Config.h"

@implementation PMEventCalendarListTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //_markView.layer.borderWidth = 1;
    _markView.layer.cornerRadius = _markView.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (void)configureCell:(DBCalendar*)calendar selected:(BOOL)selected {
    _calendar = calendar;
    _titleLabel.text = calendar.name;
    UIColor *lCalendarColor = [CALENDAR_COLORS objectAtIndex:[calendar.color integerValue]];
    _markView.layer.borderColor = lCalendarColor.CGColor;
    _markView.backgroundColor = [CALENDAR_COLORS objectAtIndex:[calendar.color integerValue]];
    
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
