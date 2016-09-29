//
//  WKConnectivityManager.m
//  planckMailiOS
//
//  Created by nazar on 11/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "WKConnectivityManager.h"

@implementation WKConnectivityManager
+(WKConnectivityManager*)sharedManager {

    static WKConnectivityManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WKConnectivityManager alloc] init];
        
    });
    
    return manager;
}

-(void)handleIphoneReplyMessage:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {

    
    NSLog(@"handleIphoneReplyMessage");

    
}

@end
