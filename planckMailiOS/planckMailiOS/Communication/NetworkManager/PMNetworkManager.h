//
//  PMNetworkManager.h
//  planckMailiOS
//
//  Created by admin on 8/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "AFNetworking.h"

@interface PMNetworkManager : AFHTTPSessionManager

+ (PMNetworkManager *)sharedPMNetworkManager;
- (instancetype)initWithBaseURL:(NSURL *)url;

@property(nonatomic, copy) NSString *currentToken;

@end
