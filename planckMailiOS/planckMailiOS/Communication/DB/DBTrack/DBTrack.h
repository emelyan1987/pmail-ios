//
//  DBTrack.h
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBTrack : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(DBTrack *)createOrUpdateTrackWithData:(NSDictionary *)data onContext:(NSManagedObjectContext*)context;
+(DBTrack *)getTrackWithId:(NSNumber*)trackId;
+(DBTrack *)getTrackWithId:(NSNumber*)trackId onContext:(NSManagedObjectContext*)context;

- (NSDictionary*)toDictionary;
@end

NS_ASSUME_NONNULL_END

#import "DBTrack+CoreDataProperties.h"
