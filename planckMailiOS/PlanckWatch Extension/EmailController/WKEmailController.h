//
//  WKEmailController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKBaseController.h"

@import WatchConnectivity;

#define EMAIL_CONTROLLER_IDENTIFIER @"emailController"

@interface WKEmailController : WKBaseController <WCSessionDelegate>

@end
