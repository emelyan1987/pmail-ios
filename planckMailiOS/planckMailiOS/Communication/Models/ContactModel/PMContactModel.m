//
//  PMContactModel.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactModel.h"

@implementation PMContactModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

-(instancetype)initWithData:(NSDictionary *)data
{
    self.id = data[@"id"];
    self.name = data[@"name"];
    self.company = data[@"company"];
    self.job = data[@"job"];
    self.address = data[@"address"];
    self.email = data[@"emails"][0];
    self.phoneNumbers = data[@"phone_numbers"];
    self.emails = data[@"emails"];
    self.profileData = data[@"profile_data"];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    PMContactModel *contact = [PMContactModel new];
    
    contact.name = [aDecoder decodeObjectForKey:@"name"];
    contact.email = [aDecoder decodeObjectForKey:@"email"];
    contact.phoneNumbers = [aDecoder decodeObjectForKey:@"phoneNumbers"];
    
    return contact;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_phoneNumbers forKey:@"phoneNumbers"];
}
@end
