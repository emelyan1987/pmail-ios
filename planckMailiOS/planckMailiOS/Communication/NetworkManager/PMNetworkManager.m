//
//  PMNetworkManager.m
//  planckMailiOS
//
//  Created by admin on 8/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMNetworkManager.h"
#import "Config.h"

#ifndef PLANCK_SYNC_ENGINE
#define BASE_SERVER_LINK @"https://api.nylas.com"
#else
#define BASE_SERVER_LINK @"https://sync-dev.planckapi.com"
#endif

@implementation PMNetworkManager

+ (PMNetworkManager *)sharedPMNetworkManager {
    static PMNetworkManager *sSharedPMNetworkManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedPMNetworkManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_SERVER_LINK]];
    });
    
    return sSharedPMNetworkManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)setCurrentToken:(NSString *)currentToken {
    _currentToken = currentToken;
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:_currentToken ? : @"" password:@""];
}

@end
