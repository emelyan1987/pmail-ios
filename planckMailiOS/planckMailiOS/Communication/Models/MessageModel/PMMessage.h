//
//  PMMessageModel.h
//  planckMailiOS
//
//  Created by admin on 7/12/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMMessage : NSObject
@property(nonatomic, copy) NSArray *bcc;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy) NSArray *cc;
@property(nonatomic, copy) NSString *date;
@property(nonatomic, copy) NSArray *events;
@property(nonatomic, copy) NSArray *files;
@property(nonatomic, copy) NSArray *from;
@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *namespaceId;
@property(nonatomic, copy) NSString *object;
@property(nonatomic, copy) NSArray *replyTo;
@property(nonatomic, copy) NSString *snippet;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *threadId;
@property(nonatomic, copy) NSArray *to;
@property(nonatomic, copy) NSString *unread;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
