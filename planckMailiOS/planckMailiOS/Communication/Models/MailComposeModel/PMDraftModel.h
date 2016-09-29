//
//  PMMailComposeModel.h
//  planckMailiOS
//
//  Created by admin on 7/23/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMDraftModel : NSObject
@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSArray *to;
@property(nonatomic, copy) NSArray *from;
@property(nonatomic, copy) NSArray *reply_to;
@property(nonatomic, copy) NSArray *cc;
@property(nonatomic, copy) NSArray *bcc;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy) NSString *replyBody;
@property(nonatomic, copy) NSNumber *version;
@end
