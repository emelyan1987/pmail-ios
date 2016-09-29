//
//  OPDataLoader.h
//  Telemedecine Centre
//
//  Created by LHlozhyk on 05/25/15.
//  Copyright (c) 2013 PlanckLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GetDataLoaderHandler)(NSData *loadData, NSError *error, BOOL success);

/*!
 ## OPDataLoader ##
 This class provides loading data from server
 */
@interface OPDataLoader : NSObject <NSURLConnectionDataDelegate> {
    NSMutableData *mLoadingData; /*!< finished loading data */
}
@property (nonatomic, copy) NSString *token;

- (void)restartConection;

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl handler:(GetDataLoaderHandler)handler; /*!< simple method to get data from url with POST method*/

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl authorization:(NSString *)authorization handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl parameterString:(NSString *)parameterString handler:(GetDataLoaderHandler)handler; /*!< method that get data from url with POST method and input parameters of Url */

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl
               JSONParameters:(NSDictionary*)jsonDic
                      handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithGETMethod:(NSString *)strUrl handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithGETMethod:(NSString *)strUrl authorization:(NSString *)authorization handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithGETMethod:(NSString *)strUrl HTTPHeader:(NSDictionary*)headerDic handler:(GetDataLoaderHandler)handler;

- (void)loadURLWithDELETEMethod:(NSString *)strUrl  authorization:(NSString *)authorization handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithPOSTMethod:(NSString *)strUrl JSONStringParameters:(NSString*)jsonSting authorization:(NSString *)authorization handler:(GetDataLoaderHandler)handler;

- (void)loadUrlWithPUTMethod:(NSString *)strUrl
              JSONParameters:(NSDictionary *)jsonDic
                     handler:(GetDataLoaderHandler)handlerl;

@end
