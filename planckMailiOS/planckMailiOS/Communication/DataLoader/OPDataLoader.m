//
//  OPDataLoader.m
//  Telemedecine Centre
//
//  Created by LHlozhyk on 05/24/15.
//  Copyright (c) 2013 PlanckLab. All rights reserved.
//

#import "OPDataLoader.h"

#define TIME_OUT 15.0f

@interface OPDataLoader () {
    NSURLConnection *connection;
}
- (NSMutableURLRequest*)requestWithURL:(NSURL *)url
                            HTTPMethod:(NSString *)httpMethod
                            HTTPHeader:(NSDictionary *)header
                              HTTPBody:(NSData *)body;

- (void)startLoadWithRequest:(NSURLRequest *)request;

@property(nonatomic, copy)void (^OnGetDataLoader)(NSData *, NSError *error, BOOL success);
@end

@implementation OPDataLoader

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
                      handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                         HTTPMethod:@"POST"
                                         HTTPHeader:nil
                                           HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
                authorization:(NSString *)authorization
                      handler:(GetDataLoaderHandler)handler {
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                       HTTPMethod:@"POST"
                                       HTTPHeader:@{@"Authorization":authorization}
                                         HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
              parameterString:(NSString *)parameterString
                      handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSData *lPostData = [parameterString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *lPostLength = [NSString stringWithFormat:@"%lu",(unsigned long)[lPostData length]];
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                         HTTPMethod:@"POST"
                                         HTTPHeader:@{@"Content-Length":lPostLength}
                                           HTTPBody:lPostData];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
               JSONParameters:(NSDictionary*)jsonDic
                      handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSError *error;
    NSData *lPostData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *lRequestData = [[NSString alloc] initWithData:lPostData encoding:NSUTF8StringEncoding];
    NSString *lPostLength = [NSString stringWithFormat:@"%lu",(unsigned long)[lRequestData length]];
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                         HTTPMethod:@"POST"
                                         HTTPHeader:@{@"Content-Type":@"application/json",
                                                      @"Content-Length":lPostLength}
                                           HTTPBody:[lRequestData dataUsingEncoding:NSUTF8StringEncoding]];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
               JSONStringParameters:(NSString*)jsonSting
                authorization:(NSString *)authorization
                      handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSData *lPostData = [jsonSting dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *lPostLength = [NSString stringWithFormat:@"%lu",(unsigned long)[lPostData length]];
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                       HTTPMethod:@"POST"
                                       HTTPHeader:@{@"Content-Type":@"application/json",
                                                    @"Authorization":authorization,
                                                    @"Content-Length":lPostLength}
                                         HTTPBody:lPostData];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithPUTMethod:(NSString *)strUrl
               JSONParameters:(NSDictionary *)jsonDic
                      handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSError *error;
    NSData *lPostData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    
    NSString *lRequestData = [[NSString alloc] initWithData:lPostData encoding:NSUTF8StringEncoding];
    NSString *lPostLength = [NSString stringWithFormat:@"%lu",(unsigned long)[lRequestData length]];
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                       HTTPMethod:@"PUT"
                                       HTTPHeader:@{@"Content-Type":@"application/json",
                                                    @"Content-Length":lPostLength}
                                         HTTPBody:[lRequestData dataUsingEncoding:NSUTF8StringEncoding]];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithGETMethod:(NSString *)strUrl
                     handler:(GetDataLoaderHandler)handler {
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                       HTTPMethod:@"GET"
                                       HTTPHeader:nil
                                         HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithGETMethod:(NSString *)strUrl
               authorization:(NSString *)authorization
                     handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                         HTTPMethod:@"GET"
                                         HTTPHeader:@{@"Authorization":authorization}
                                           HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}

- (void)loadUrlWithGETMethod:(NSString *)strUrl
                  HTTPHeader:(NSDictionary *)headerDic
                     handler:(GetDataLoaderHandler)handler {
    
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                         HTTPMethod:@"GET"
                                         HTTPHeader:headerDic
                                           HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}


- (void)loadURLWithDELETEMethod:(NSString *)strUrl authorization:(NSString *)authorization handler:(GetDataLoaderHandler)handler {
    self.OnGetDataLoader = handler;
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:strUrl]
                                       HTTPMethod:@"DELETE"
                                       HTTPHeader:@{@"Authorization":authorization}
                                         HTTPBody:nil];
    [self startLoadWithRequest:lRequest];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *lCredential = [NSURLCredential credentialWithUser:_token ? : @""
                                       password:@""
                                    persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:lCredential forAuthenticationChallenge:challenge];
    } else {
        [self onGetDataLoader:nil error:nil success:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [mLoadingData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self onGetDataLoader:mLoadingData error:nil success:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    DLog(@"didFailWithError:%@", error.description);
    [self onGetDataLoader:nil error:error success:NO];
}

#pragma mark - privates

- (void)startLoadWithRequest:(NSURLRequest *)request {
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mLoadingData = [NSMutableData new];
        DLog(@"connection successful");
    } else {
        DLog(@"connection failed");
    }
    [connection start];
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                            HTTPMethod:(NSString *)httpMethod
                            HTTPHeader:(NSDictionary *)header
                              HTTPBody:(NSData *)body {
    NSMutableURLRequest *lNewRequest = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                    timeoutInterval:TIME_OUT];
    [lNewRequest setHTTPMethod:httpMethod];
    
    if (header) {
        for (NSString *key in header) {
            id value = [header objectForKey:key];
            [lNewRequest setValue:value forHTTPHeaderField:key];
        }
    }
    
    if (body) {
        [lNewRequest setHTTPBody:body];
    }
    
    return lNewRequest;
}

- (void)onGetDataLoader:(NSData *)data error:(NSError *)error success:(BOOL)success {
    DLog(@"Log data :%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if ([self OnGetDataLoader]) {
        
        [self OnGetDataLoader](data, error, success);
    }
}

- (void)restartConection {
    [connection start];
}


@end
