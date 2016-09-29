//
//  NSArray+DBContact.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSArray+DBMessage.h"

@implementation NSArray(DBMessage)

-(BOOL)isContainMessage:(DBMessage *)message
{
    for(DBMessage *model in self)
    {
        if([model.id isEqualToString:message.id])
            return YES;
    }
    
    return NO;
}
@end
