//
//  DBMailAdditionalInfo.h
//  planckMailiOS
//
//  Created by LionStar on 2/23/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBMailAdditionalInfo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBMailAdditionalInfo *)createOrUpdateMailAdditionalInfoWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithMessageId:(NSString *)messageId;
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithMessageId:(NSString *)messageId context:(NSManagedObjectContext*)context;
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithThreadId:(NSString *)threadId;
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithThreadId:(NSString *)threadId context:(NSManagedObjectContext*)context;

- (NSDictionary*)convertToDictionary;
@end

NS_ASSUME_NONNULL_END

#import "DBMailAdditionalInfo+CoreDataProperties.h"
