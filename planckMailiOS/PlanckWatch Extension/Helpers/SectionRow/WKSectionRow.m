//
//  WKSectionRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKSectionRow.h"
#import <WatchKit/WatchKit.h>

@implementation WKSectionRow

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

@end
