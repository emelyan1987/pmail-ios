//
//  PMMailComposeTimeSlotTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeTimeSlotTVCell.h"
#import "Config.h"
@interface PMMailComposeTimeSlotTVCell()
{
    NSTimeInterval selectedTime;
    NSMutableArray *_timeSlotButtonArray;
}

@end
@implementation PMMailComposeTimeSlotTVCell

- (void)awakeFromNib {
    // Initialization code
    _timeSlotButtonArray = [NSMutableArray new];
    self.btnOtherTimes.layer.cornerRadius = self.btnOtherTimes.frame.size.height/2;
    
    self.otherTimeLabel.layer.masksToBounds = YES;
    self.otherTimeLabel.layer.cornerRadius = self.otherTimeLabel.frame.size.height/2;
    self.otherTimeLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureTimeSlotWithData:(NSDictionary *)data
{
    for(UIView *view in self.timeSlotView.subviews)
    {
        [view removeFromSuperview];
    }
    [self performSelector:@selector(buildTimeSlotWithData:) withObject:data afterDelay:.1];
}

- (void)buildTimeSlotWithData:(NSDictionary*)data
{
    CGFloat slotWidth = 80;
    CGFloat slotHeight = 25;
    
    CGFloat timeSlotViewWidth = self.timeSlotView.frame.size.width;
    CGFloat hGap = (timeSlotViewWidth - (slotWidth * 3)) / 4;
    CGFloat vGap = 10;
    CGFloat maxHeight = 0;
    
    NSArray *dates = [data allKeys];
    for(NSInteger i=0; i<dates.count; i++)
    {
        NSString *date = dates[i];
        NSArray *times = [data objectForKey:date];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(hGap + i * (slotWidth + hGap), vGap, slotWidth, slotHeight)];
        dateLabel.text = date;
        dateLabel.textColor = UIColorFromRGB(0x007AFF);
        dateLabel.font = font;
        dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.timeSlotView addSubview:dateLabel];
        
        CGFloat height = dateLabel.frame.origin.y + dateLabel.frame.size.height;
        
        for(NSInteger j=0; j<times.count; j++)
        {
            NSDate *time = times[j];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            
            UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(hGap + i * (slotWidth + hGap), 2*vGap + slotHeight + j * (slotHeight + vGap), slotWidth, slotHeight)];
            [timeButton setTitle:[[dateFormatter stringFromDate:time] lowercaseString] forState:UIControlStateNormal];
            [timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [timeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [timeButton setBackgroundColor:UIColorFromRGB(0x5AC4B4)];
            [timeButton.titleLabel setFont:font];
            timeButton.layer.cornerRadius = slotHeight / 2;
            [timeButton addTarget:self action:@selector(timeSlotButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [timeButton setTag:[time timeIntervalSince1970]];
            
            [self.timeSlotView addSubview:timeButton];
            [_timeSlotButtonArray addObject:timeButton];
            
            height = timeButton.frame.origin.y + timeButton.frame.size.height;
        }
        
        if(maxHeight < height) maxHeight = height;
    }
    
    self.timeSlotViewHeightConstraint.constant = maxHeight + vGap;
    
    //if([self.delegate respondsToSelector:@selector(timeSlotCell:didConfigureTimeSlotView:)])
        //[self.delegate timeSlotCell:self didConfigureTimeSlotView:[self height]];
}

-(void)timeSlotButtonClicked:(id)sender
{
    
    for(UIButton *btn in _timeSlotButtonArray)
    {
        if([btn isEqual:sender])
        {
            [btn setBackgroundColor:UIColorFromRGB(0x007AFF)];
            
            selectedTime = btn.tag;
            
            if([self.delegate respondsToSelector:@selector(timeSlotCell:didSelectTime:)])
                [self.delegate timeSlotCell:self didSelectTime:selectedTime];
        }
        else
        {
            [btn setBackgroundColor:UIColorFromRGB(0x5AC4B4)];
        }
    }
    
    self.otherTime = nil;
    self.otherTimeLabel.hidden = YES;
}
-(CGFloat)height
{
    return self.timeSlotViewHeightConstraint.constant+self.otherTimeView.frame.size.height;
}
- (IBAction)btnOtherTimePressed:(id)sender
{
    for(UIButton *btn in _timeSlotButtonArray)
    {
        
        [btn setBackgroundColor:UIColorFromRGB(0x5AC4B4)];
        
    }
    
    if([self.delegate respondsToSelector:@selector(timeSlotCell:willSelectOtherTime:)])
        [self.delegate timeSlotCell:self willSelectOtherTime:sender];
}
@end
