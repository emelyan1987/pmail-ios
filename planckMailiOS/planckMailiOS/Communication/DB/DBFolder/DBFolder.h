//
//  DBFolder.h
//  planckMailiOS
//
//  Created by LionStar on 6/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBFolder : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (DBFolder*)createOrUpdateWithData:(NSDictionary*)data;
+ (DBFolder*)getFolderWithId:(NSString *)folderId;
+ (void)setUnreads:(NSNumber*)unreads forFolder:(NSString*)folderId;


- (NSDictionary*)toDictionary;
@end

NS_ASSUME_NONNULL_END

#import "DBFolder+CoreDataProperties.h"
