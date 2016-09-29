//
//  PMMessageModel.m
//  planckMailiOS
//
//  Created by admin on 7/12/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMessage.h"

@implementation PMMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _body = dictionary[@"body"];
        
    }
    return self;
}

@end
