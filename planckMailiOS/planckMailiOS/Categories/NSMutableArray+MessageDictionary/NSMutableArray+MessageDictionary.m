//
//  NSArray+DBContact.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSMutableArray+MessageDictionary.h"

@implementation NSMutableArray(MessageDictionary)

-(BOOL)containsMessageWithId:(NSString *)messageId
{
    for(NSDictionary *message in self)
    {
        if([messageId isEqualToString:message[@"id"]])
            return YES;
    }
    

    
    
    return NO;
}
@end
