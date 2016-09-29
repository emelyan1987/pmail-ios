//
//  WKContactInfoController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "WKBaseController.h"

@import WatchConnectivity;

#define CONTACTS_INFO_IDENT @"contactInfoController"

@interface WKContactInfoController : WKBaseController <WCSessionDelegate>

- (instancetype)initWithContactNames:(NSDictionary *)names;

@end
