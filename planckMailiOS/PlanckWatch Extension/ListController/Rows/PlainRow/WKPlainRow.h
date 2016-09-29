//
//  WKPlainRow.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#define PLAIN_ROW_IDENTIFIER @"plainType"

@class PMTypeContainer;
@interface WKPlainRow : NSObject

- (void)setTypeContainer:(PMTypeContainer *)typeContainer;
- (void)setTitle:(NSString *)title;

@end
