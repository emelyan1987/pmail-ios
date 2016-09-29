//
//  WKContactPhonesController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
@import WatchConnectivity;
#define CONTACTS_PHONE_IDENT @"contactPhoneController"

typedef NS_ENUM(NSInteger, PMRequestType) {
  PMRequestCall,
  PMRequestMessage
};

@interface WKContactPhonesController : WKInterfaceController <WCSessionDelegate>

@end
