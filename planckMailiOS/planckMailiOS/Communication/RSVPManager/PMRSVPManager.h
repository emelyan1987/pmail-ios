//
//  PMRSVPManager.h
//  planckMailiOS
//
//  Created by LionStar on 2/2/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RSVP_TYPE) {
    RSVP_TYPE_ACCEPT,
    RSVP_TYPE_TENTATIVE,
    RSVP_TYPE_DECLINE
};

@interface PMRSVPManager : NSObject

+(PMRSVPManager*)sharedInstance;
-(void)sendRSVPByMessageId:(NSString*)messageId type:(RSVP_TYPE)type completion:(void(^)(id data, NSError *error))handler;
-(void)sendRSVP:(NSString*)eventId type:(RSVP_TYPE)type completion:(void(^)(id data, NSError *error))handler;
@end
