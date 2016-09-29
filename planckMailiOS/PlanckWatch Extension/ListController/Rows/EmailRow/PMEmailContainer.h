//
//  PMEmailContainer.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMEmailContainer : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) BOOL isUnread;

+ (instancetype)initWithTitle:(NSString *)title subject:(NSString *)subject text:(NSString *)text date:(NSDate *)date isUnread:(BOOL)unread;

@end
