//
//  PMTrackModel.h
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMTrackModel : NSObject

@property (nonatomic, assign) NSNumber *trackId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *ownerEmail;
@property (nonatomic, strong) NSString *targetEmails;
@property (nonatomic, strong) NSNumber *opens;
@property (nonatomic, strong) NSNumber *clicks;
@property (nonatomic, strong) NSNumber *replies;
@property (nonatomic, strong) NSDate *createdTime;
@property (nonatomic, strong) NSDate *modifiedTime;

@end
