//
//  BSPerson.h
//
//
//  Created by Chirag Lakhani on 03/08/13.
//  Copyright (c) 2013 Chirag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PHONE_NUMBER @"phone_number"
#define PHONE_TITLE @"phone_title"

#define PERSON_NAME         @"person_name"
#define PERSON_SECOND_NAME  @"person_second_name"

@interface CLPerson : NSObject <NSSecureCoding>


@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSArray *emails;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) NSArray *phoneNumbers;
@property (nonatomic,strong) UIImage *personImage;
@property (nonatomic,copy) NSString *fullName;
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *company;
@property (nonatomic,copy) NSString *job;
@property (nonatomic,copy) NSDate *birthday;

@property(nonatomic,strong) NSString  *personID;


@property(nonatomic,strong)NSString  *personImageURl;

@end
