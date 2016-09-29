//
//  DBTrackDetail.h
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBTrackDetail : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(DBTrackDetail *)createOrUpdateTrackDetailWithData:(NSDictionary *)data onContext:(NSManagedObjectContext*)context;
+(DBTrackDetail *)getTrackDetailWithId:(NSNumber*)trackId;
+(DBTrackDetail *)getTrackDetailWithId:(NSNumber*)trackId context:(NSManagedObjectContext*)context;

- (NSDictionary*)toDictionary;

@end

NS_ASSUME_NONNULL_END

#import "DBTrackDetail+CoreDataProperties.h"
