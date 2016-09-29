//
//
//
//
//  Created by Chirag Lakhani on 03/08/13.
//  Copyright (c) 2013 Chirag. All rights reserved.
//

#import "CLPerson.h"

@implementation CLPerson

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  CLPerson *person = [CLPerson new];
  
  person.firstName = [aDecoder decodeObjectForKey:@"firstName"];
  person.lastName = [aDecoder decodeObjectForKey:@"lastName"];
  person.email = [aDecoder decodeObjectForKey:@"email"];
  person.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
  person.phoneNumbers = [aDecoder decodeObjectForKey:@"phoneNumbers"];
  person.personImage = [aDecoder decodeObjectForKey:@"personImage"];
  person.fullName = [aDecoder decodeObjectForKey:@"fullName"];
  person.personImageURl = [aDecoder decodeObjectForKey:@"personImageURl"];
  
  return person;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_firstName forKey:@"firstName"];
  [aCoder encodeObject:_lastName forKey:@"lastName"];
  [aCoder encodeObject:_email forKey:@"email"];
  [aCoder encodeObject:_phoneNumber forKey:@"phoneNumber"];
  [aCoder encodeObject:_phoneNumbers forKey:@"phoneNumbers"];
  [aCoder encodeObject:_personImage forKey:@"personImage"];
  [aCoder encodeObject:_fullName forKey:@"fullName"];
  [aCoder encodeObject:_personImageURl forKey:@"personImageURl"];
}

@end
