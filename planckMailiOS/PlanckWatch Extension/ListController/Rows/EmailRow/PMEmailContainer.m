//
//  PMEmailContainer.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEmailContainer.h"

@implementation PMEmailContainer

+ (instancetype)initWithTitle:(NSString *)title subject:(NSString *)subject text:(NSString *)text date:(NSDate *)date isUnread:(BOOL)unread {
  PMEmailContainer *newContainer = [PMEmailContainer new];
  
  newContainer.title = title?:@"";
  newContainer.subject = subject?:@"";
  newContainer.text = text?:@"";
  newContainer.date = date?:[NSDate date];
  newContainer.isUnread = unread;
  
  return newContainer;
}

@end
