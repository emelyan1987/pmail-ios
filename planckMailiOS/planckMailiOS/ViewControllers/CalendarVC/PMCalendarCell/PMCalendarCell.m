//
//  PMCalendarCell.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarCell.h"
#import "PMEventModel.h"
#import "NSDate+DateConverter.h"
#import "DBManager.h"
#import "Config.h"

@interface PMCalendarCell ()

@end

@implementation PMCalendarCell
+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMCalendarCell" owner:nil options:nil];
    PMCalendarCell *cell = [cellsXIB firstObject];
    
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _calendarColorView.layer.cornerRadius = _calendarColorView.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEvent:(PMEventModel *)event {
    _titleLabel.text = event.title;
    _locationLabel.text = event.location;
    _calendarColorView.backgroundColor = [UIColor clearColor];
    
    
    _calendarColorView.backgroundColor = [event getColor];   
    
    
    NSString *timeText = @"";
    
    _durationLabel.hidden = NO;
    
    switch (event.eventDateType) {
        case EventDateTimeType: {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            timeText = [date timeStringValue];
            
            _durationLabel.hidden = YES;
        }
            break;
            
        case EventDateTimespanType: {
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[event.endTime doubleValue]];
            timeText = [NSString stringWithFormat:@"%@", [startDate timeStringValue]];
            
            NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
            NSInteger hours = interval/(60*60);
            NSInteger mins = (interval - hours*3600)/60;
            NSMutableString *durationText = [NSMutableString new];
            if(hours>0) [durationText appendFormat:@"%dh", (int)hours];
            if(mins>0) (durationText.length>0)?[durationText appendFormat:@" %dm", (int)mins]:[durationText appendFormat:@"%dm", (int)mins];
            _durationLabel.text = durationText;
        }
            
            
            break;
            
        case EventDateDateType: {
            timeText = @"All Day";
            _durationLabel.hidden = YES;
        }
            break;
            
        case EventDateDatespanType: {
            NSDate *startDate = [NSDate eventDateFromString:event.startTime];
            NSDate *endDate = [NSDate eventDateFromString:event.endTime];
            
            timeText = @"All Day";
            _durationLabel.text = [NSString stringWithFormat:@"%dd", (int)[endDate timeIntervalSinceDate:startDate]/(60*60*24)+1];
        }
            
            break;
            
        default:
            break;
    }
    DLog(@"time text - %@", timeText);
    _timeLabel.text = timeText;
}

@end
