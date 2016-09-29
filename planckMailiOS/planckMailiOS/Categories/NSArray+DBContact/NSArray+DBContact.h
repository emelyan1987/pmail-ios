//
//  NSArray+DBContact.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBContact.h"

@interface NSArray(DBContact)

-(DBContact*)getDBContactWithEmail:(NSString*)email;
@end
