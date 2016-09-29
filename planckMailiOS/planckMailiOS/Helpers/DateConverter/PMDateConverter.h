//
//  PMDateConverter.h
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMDateConverter : NSObject

+(NSString*)getStringDateFromDate:(NSDate*)date;

+(int)getDifferenceFromDate:(NSDate*)date;

+(NSString*)getStringDateWithCustomFormatFromDate:(NSDate*)date;

@end
