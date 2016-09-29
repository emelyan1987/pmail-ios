//
//  PMTypeContainer.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMTypeContainer.h"
#import "DBNamespace.h"


@implementation PMTypeContainer

@synthesize id;
@synthesize account_id;
@synthesize namespace_id;
@synthesize token;

+ (instancetype)initWithTitle:(NSString *)title count:(NSInteger)count {
  PMTypeContainer *newType = [[PMTypeContainer alloc] init];
  newType.provider = title;
  newType.email_address = title;
  newType.unreadCount = count;
  return newType;
}

+ (instancetype)initWithNameSpase:(DBNamespace *)nameSpace {
  PMTypeContainer *newType = [[PMTypeContainer alloc] init];
  
  newType.id = nameSpace.id;
  newType.object = nameSpace.object;
  newType.namespace_id = nameSpace.namespace_id;
  newType.account_id = nameSpace.account_id;
  newType.email_address = nameSpace.email_address;
  newType.name = nameSpace.name;
  newType.provider = nameSpace.provider;
  newType.token = nameSpace.token;
  newType.isNameSpace = YES;
  newType.unreadCount = [nameSpace.unreadCount integerValue];
  
  return newType;
}

//- (BOOL)isEqual:(id)object {
//    if(![object isKindOfClass:[PMTypeContainer class]]) {
//        return NO;
//    }
//    
//    PMTypeContainer *obj = object;
//    
//    return [obj.namespace_id isEqualToString:self.namespace_id] && [obj.email_address isEqualToString:self.email_address] && [obj.token isEqualToString:self.token];
//}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.id forKey:@"id"];
  [aCoder encodeObject:self.object forKey:@"object"];
  [aCoder encodeObject:self.namespace_id forKey:@"namespace_id"];
  [aCoder encodeObject:self.account_id forKey:@"account_id"];
  [aCoder encodeObject:self.email_address forKey:@"email_address"];
  [aCoder encodeObject:self.name forKey:@"name"];
  [aCoder encodeObject:self.provider forKey:@"provider"];
  [aCoder encodeObject:self.token forKey:@"token"];
  [aCoder encodeBool:self.isNameSpace forKey:@"isNameSpace"];
  [aCoder encodeObject:[NSNumber numberWithInteger:_unreadCount] forKey:@"unreadCount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  PMTypeContainer *newType = [PMTypeContainer new];
  
  newType.id = [aDecoder decodeObjectForKey:@"id"];
  newType.object = [aDecoder decodeObjectForKey:@"object"];
  newType.namespace_id = [aDecoder decodeObjectForKey:@"namespace_id"];
  newType.account_id = [aDecoder decodeObjectForKey:@"account_id"];
  newType.email_address = [aDecoder decodeObjectForKey:@"email_address"];
  newType.name = [aDecoder decodeObjectForKey:@"name"];
  newType.provider = [aDecoder decodeObjectForKey:@"provider"];
  newType.token = [aDecoder decodeObjectForKey:@"token"];
  newType.isNameSpace = [aDecoder decodeBoolForKey:@"isNameSpace"];
  newType.unreadCount = [[aDecoder decodeObjectForKey:@"unreadCount"] integerValue];
  
  return newType;
}

#pragma mark - Overridden methods

- (BOOL)isEqual:(id)object {
  if(![object isKindOfClass:[PMTypeContainer class]]) return NO;
  
  PMTypeContainer *typeObject = (PMTypeContainer *)object;
  return [typeObject.id isEqualToString:self.id] && [typeObject.namespace_id isEqualToString:self.namespace_id] && [typeObject.account_id isEqualToString:self.account_id] && [typeObject.token isEqualToString:self.token];
}

#pragma mark - PMAccountProtocol



@end
