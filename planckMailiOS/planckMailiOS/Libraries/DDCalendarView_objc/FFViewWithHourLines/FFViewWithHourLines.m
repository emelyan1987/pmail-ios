//
//  FFViewWithHourLines.m
//  FFCalendar
//
//  Created by Fernanda G. Geraissate on 2/21/14.
//  Copyright (c) 2014 Fernanda G. Geraissate. All rights reserved.
//
//  http://fernandasportfolio.tumblr.com
//

#import "FFViewWithHourLines.h"
#import "FFHourAndMinLabel.h"
#import "NSDate+DDCalendar.h"
#import "UILabel+FFCustomMethods.h"
#import "DDCalendarViewConstants.h"

@interface FFViewWithHourLines ()
@property (strong) NSMutableArray *arrayLabelsHourAndMin;
@property (assign) CGFloat totalHeight;

@property (strong) FFHourAndMinLabel *labelForNow;
@end

@implementation FFViewWithHourLines

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrayLabelsHourAndMin = [NSMutableArray new];
        
        CGFloat y = 0;
        
        
        
        //add today time lines
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                FFHourAndMinLabel *labelHourMin = [[FFHourAndMinLabel alloc] initWithFrame:CGRectMake(10, y, self.frame.size.width-10, HEIGHT_CELL_MIN) date:[NSDate todayDateWithHour:hour min:min]];
                [labelHourMin setTextColor:[UIColor grayColor]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    width = 50;
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x, 0, self.frame.size.width, 1.)];
                    [view setBackgroundColor:[UIColor lightGrayColor]];
                    [labelHourMin addSubview:view];
                }
                else if (min == 30) {
                    //[labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x, 0, self.frame.size.width, 0.5)];
                    [view setBackgroundColor:[UIColor lightGrayColor]];
                    [labelHourMin addSubview:view];
                }
                [self addSubview:labelHourMin];
                [self.arrayLabelsHourAndMin addObject:labelHourMin];
                
                y += HEIGHT_CELL_MIN;
            }
        }
        

        //add tommorrow (hc)
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                FFHourAndMinLabel *labelHourMin = [[FFHourAndMinLabel alloc] initWithFrame:CGRectMake(10, y, self.frame.size.width-10, HEIGHT_CELL_MIN) date:[NSDate tomorrowDateWithHour:hour min:min]];
                [labelHourMin setTextColor:[UIColor grayColor]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x+width, HEIGHT_CELL_MIN/2., self.frame.size.width-labelHourMin.frame.origin.x-width, 1.)];
                    [view setBackgroundColor:[UIColor lightGrayColor]];
                    [labelHourMin addSubview:view];
                }
                [self addSubview:labelHourMin];
                [self.arrayLabelsHourAndMin addObject:labelHourMin];
                
                y += HEIGHT_CELL_MIN;
            }
        }
        
        self.totalHeight = y;
        
        [self addCurrentTimeLine];
        
        [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeHandler) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)sizeToFit {
    CGRect f = self.frame;
    f.size.height = self.totalHeight;
    self.frame = f;
}

-(void)addCurrentTimeLine
{
    // add current time line
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    _labelForNow = [[FFHourAndMinLabel alloc] initWithFrame:CGRectMake(10, PIXELS_PER_MIN*(hour*60+minute), self.frame.size.width-10, HEIGHT_CELL_MIN) date:today];
    [_labelForNow setTextColor:[UIColor redColor]];
    [_labelForNow setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [_labelForNow showTextWithMin];
    CGFloat width = [_labelForNow widthThatWouldFit];
    width = 50;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_labelForNow.frame.origin.x, HEIGHT_CELL_MIN/2.-10, self.frame.size.width, 1.)];
    [view setBackgroundColor:[UIColor redColor]];
    [_labelForNow addSubview:view];
    
    
    
    CGRect labelForNowFrame = _labelForNow.frame;
    for(FFHourAndMinLabel *label in self.arrayLabelsHourAndMin)
    {
        if(label.showedText)
        {
            CGRect labelFrame = label.frame;
            CGFloat dy = labelForNowFrame.origin.y - labelFrame.origin.y;
            if(dy > -HEIGHT_CELL_MIN && dy < HEIGHT_CELL_MIN)
            {
                [label hideText];
            }
            else
            {
                [label showText];
            }
        }
    }
    
    [self addSubview:_labelForNow];
    [self.arrayLabelsHourAndMin addObject:_labelForNow];
    
}

-(void)updateCurrentTimeLine
{
    if(_labelForNow)
    {
        [_labelForNow removeFromSuperview];
        [_arrayLabelsHourAndMin removeObject:_labelForNow];
    }
    
    [self addCurrentTimeLine];
}

-(void)timeHandler
{
    [self updateCurrentTimeLine];
}
@end
