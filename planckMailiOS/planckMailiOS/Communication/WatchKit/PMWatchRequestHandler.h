//
//  PMWatchRequestHandler.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WatchConnectivity;

@interface PMWatchRequestHandler : NSObject

+ (instancetype)sharedHandler;
- (void)handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply;

@end
