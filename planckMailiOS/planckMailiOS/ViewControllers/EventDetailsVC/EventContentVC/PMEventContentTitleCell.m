//
//  PMEventContentTitleCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/4/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEventContentTitleCell.h"
#import "NSDate+DateConverter.h"
#import "Config.h"
#import "PMMailManager.h"

@implementation PMEventContentTitleCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.text = @"";
    self.dateLabel.text = @"";
    self.durationLabel.text = @"";
    self.timeLabel.text = @"";
    
    self.colorMarkView.layer.cornerRadius = self.colorMarkView.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setEvent:(PMEventModel *)event
{
    NSDate *startDate = [event getStartDate];
    NSDate *endDate = [event getEndDate];
    
    DBCalendar *lCalendar = [event getCalendar];
    
    if (lCalendar) {
        self.colorMarkView.backgroundColor = [CALENDAR_COLORS objectAtIndex:[lCalendar.color integerValue]];
    }
    self.titleLabel.text = event.title;
    
    NSString *timeText = @"";
    
    _durationLabel.hidden = NO;
    
    switch (event.eventDateType) {
        case EventDateTimeType: {
            timeText = [startDate timeStringValue];
            
            _durationLabel.hidden = YES;
        }
            break;
            
        case EventDateTimespanType: {
            timeText = [NSString stringWithFormat:@"%@ - %@", [startDate timeStringValue], [endDate timeStringValue]];
            
            NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
            
            _durationLabel.text = [[PMMailManager sharedInstance] getFormattedDuration:interval];
        }
            break;
            
        case EventDateDateType: {
            timeText = @"All Day";
            _durationLabel.hidden = YES;
        }
            break;
            
        case EventDateDatespanType: {
            timeText = @"All Day";
            _durationLabel.text = [NSString stringWithFormat:@"%dd", (int)[endDate timeIntervalSinceDate:startDate]/(60*60*24)+1];
        }
            
            break;
            
        default:
            break;
    }
    DLog(@"time text - %@", timeText);
    self.timeLabel.text = timeText;
    self.dateLabel.text = [startDate relativeDateString];
    
}
@end
