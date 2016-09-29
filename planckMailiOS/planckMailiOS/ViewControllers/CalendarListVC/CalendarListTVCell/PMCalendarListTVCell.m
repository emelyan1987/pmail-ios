//
//  PMCalendarListTVCell.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarListTVCell.h"
#import "Config.h"
#import "DBManager.h"

@interface PMCalendarListTVCell () {
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIImageView *_markIV;
    
    DBCalendar *_calendar;
}
- (IBAction)selectColorBtnPressed:(id)sender;
@end

@implementation PMCalendarListTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _markIV.layer.borderWidth = 1;
    _markIV.layer.cornerRadius = _markIV.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(DBCalendar*)calendar {
    _calendar = calendar;
    _titleLabel.text = calendar.name;
    UIColor *lCalendarColor = [CALENDAR_COLORS objectAtIndex:[calendar.color integerValue]];
    _markIV.layer.borderColor = lCalendarColor.CGColor;
    _markIV.backgroundColor = [calendar.selected boolValue] ? [CALENDAR_COLORS objectAtIndex:[calendar.color integerValue]] : [UIColor whiteColor];
}

- (void)selectColorBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(PMCalendarListTVCellColorBtnDidPress:calendar:)]) {
        [_delegate PMCalendarListTVCellColorBtnDidPress:self calendar:_calendar];
    }
}

- (void)changeSelectedState {
    BOOL isSelected = ![_calendar.selected boolValue];
    _calendar.selected = [NSNumber numberWithBool:isSelected];
    [[DBManager instance] save];
    _markIV.backgroundColor = isSelected ? [CALENDAR_COLORS objectAtIndex:[_calendar.color integerValue]] : [UIColor whiteColor];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PMCalendarListTVCell:selectedState:)]) {
        [_delegate PMCalendarListTVCell:self selectedState:YES];
    }
}

@end
