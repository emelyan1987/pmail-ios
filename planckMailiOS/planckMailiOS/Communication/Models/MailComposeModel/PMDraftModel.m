//
//  PMMailComposeModel.m
//  planckMailiOS
//
//  Created by admin on 7/23/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMDraftModel.h"

@implementation PMDraftModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _subject = @"";
        _to = [NSArray array];
        _from = [NSArray array];
        _reply_to = [NSArray array];
        _bcc = [NSArray array];
        _cc = [NSArray array];
        _body = @"";
    }
    return self;
}

@end
