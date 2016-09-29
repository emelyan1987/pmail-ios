//
//  WKContactsController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.

#import "WKBaseController.h"
@import WatchConnectivity;

#define CONTACTS_LIST_IDENT @"contactsListController"

@interface WKContactsController : WKBaseController <WCSessionDelegate>

@end
