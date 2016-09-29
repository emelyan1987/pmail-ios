//
//  FFHourAndMinLabel.m
//  FFCalendar
//
//  Created by Fernanda G. Geraissate on 2/18/14.
//  Copyright (c) 2014 Fernanda G. Geraissate. All rights reserved.
//
//  http://fernandasportfolio.tumblr.com
//

#import "FFHourAndMinLabel.h"
#import "NSDate+DDCalendar.h"

@implementation FFHourAndMinLabel

#pragma mark - Synthesize

@synthesize dateHourAndMin;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date {
    
    self = [self initWithFrame:frame];
    
    if (self) {
        dateHourAndMin = date;
        UIFont * customFont = [UIFont fontWithName:@"Helvetica" size:11]; //custom font
        self.font = customFont;
        
    }
    return self;
}

- (void)showText {
    
    //NSDateComponents *comp =  dateHourAndMin.currentCalendarDateComponents;
    //[self setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)comp.hour, (long)comp.minute]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h a"];
    [self setText:[dateFormatter stringFromDate:dateHourAndMin]];
    
    self.showedText = YES;
}
- (void)showTextWithMin {
    
    //NSDateComponents *comp =  dateHourAndMin.currentCalendarDateComponents;
    //[self setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)comp.hour, (long)comp.minute]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    [self setText:[dateFormatter stringFromDate:dateHourAndMin]];
    
    self.showedText = YES;
}

- (void)hideText
{
    [self setText:@""];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
