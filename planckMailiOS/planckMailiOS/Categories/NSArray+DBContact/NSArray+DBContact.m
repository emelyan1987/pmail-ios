//
//  NSArray+DBContact.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSArray+DBContact.h"

@implementation NSArray(DBContact)

-(DBContact*)getDBContactWithEmail:(NSString *)email
{
    for(DBContact *dbContact in self)
    {
        if([email isEqualToString:dbContact.email])
            return dbContact;
    }
    
    return nil;
}
@end
