//
//  DBAccount.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBAccount : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(DBAccount*)createOrUpdateAccountWithData:(NSDictionary*)data;
+(DBAccount*)createOrUpdateAccountWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+(DBAccount *)getAccountWithAccountId:(NSString *)accountId;
+(DBAccount *)getAccountWithEmail:(NSString *)email type:(NSString*)type provider:(NSString*)provider;
+(DBAccount *)getAccountWithAccountId:(NSString *)accountId context:(NSManagedObjectContext*)context;
+(DBAccount *)getAccountWithEmail:(NSString *)email type:(NSString*)type provider:(NSString*)provider context:(NSManagedObjectContext*)context;
+ (DBAccount *)getAccountWithProvider:(NSString *)provider;
+(void)deleteAccount:(DBAccount*)account;
-(NSDictionary*)convertToDictionary;


@end

NS_ASSUME_NONNULL_END

#import "DBAccount+CoreDataProperties.h"
