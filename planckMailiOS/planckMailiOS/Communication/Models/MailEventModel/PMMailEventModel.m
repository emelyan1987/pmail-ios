//
//  PMMailEventModel.m
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMMailEventModel.h"

@implementation PMMailEventModel

-(NSDictionary*)getEventParams
{
    return nil;
}

-(NSString*)getDurationText
{
    NSString *durationText;
    
    if(self.duration == 0)
        durationText = @"None";
    else if(self.duration == 30)
        durationText = @"30 mins";
    else if(self.duration > 30)
    {
        int hours = (int)self.duration / 60;
        if(hours==1)
            durationText = @"1 hour";
        else
            durationText = [NSString stringWithFormat:@"%d hours", hours];
    }
    
    self.durationText = durationText;
    
    return durationText;

}

-(NSString*)getTimeText
{
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:self.time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d,YYYY h:mm a"];
    
    return [dateFormatter stringFromDate:time];
}
@end
