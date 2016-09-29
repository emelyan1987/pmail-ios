//
//  WKConnectivityManager.h
//  planckMailiOS
//
//  Created by nazar on 11/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WKConnectivityManager : NSObject

+(WKConnectivityManager*)sharedManager;

- (void)handleIphoneReplyMessage:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply;

@end
