//
//  NSString+Utils.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

NSString *notNullStrValue(NSString *str) {
    return [str isKindOfClass:[NSNull class]] ? nil : str;
}

NSString *notEmptyStrValue(NSString *str) {
    return !str || [str isKindOfClass:[NSNull class]] || str.length==0 ? @"" : str;
}

@end
