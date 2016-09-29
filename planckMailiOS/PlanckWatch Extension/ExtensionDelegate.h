//
//  ExtensionDelegate.h
//  PlanckWatch Extension
//
//  Created by nazar on 11/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate, WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;

+(ExtensionDelegate*)sharedInstance;
@end
