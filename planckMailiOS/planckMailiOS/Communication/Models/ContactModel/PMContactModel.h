//
//  PMContactModel.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMContactModel : NSObject <NSSecureCoding>

-(instancetype)initWithData:(NSDictionary*)data;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *job;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSArray *emails;
@property (nonatomic,strong) NSArray *phoneNumbers;
@property (nonatomic,strong) NSData *profileData;
@end
