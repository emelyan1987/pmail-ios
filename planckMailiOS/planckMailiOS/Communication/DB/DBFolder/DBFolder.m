//
//  DBFolder.m
//  planckMailiOS
//
//  Created by LionStar on 6/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "DBFolder.h"
#import "DBManager.h"

@implementation DBFolder

// Insert code here to add functionality to your managed object subclass

+ (DBFolder*)createOrUpdateWithData:(NSDictionary*)data
{
    DBManager *manager = [DBManager instance];
    NSString *folderId = data[@"id"];
    
    DBFolder *folder = [DBFolder getFolderWithId:folderId];
    
    if(!folder)
    {
        folder = (DBFolder *)[NSEntityDescription insertNewObjectForEntityForName:@"DBFolder" inManagedObjectContext:manager.mainContext];
        folder.id = folderId;
    }
    
    folder.object = data[@"object"];
    folder.accountId = data[@"account_id"];
    folder.name = notNullEmptyString(data[@"name"]);
    folder.displayName = notNullEmptyString(data[@"display_name"]);
    
    [manager save];
    return folder;
}

+ (void)setUnreads:(NSNumber *)unreads forFolder:(NSString *)folderId
{
    DBFolder *folder = [DBFolder getFolderWithId:folderId];
    
    if(!folder) return;
    
    folder.unreads = unreads;
    
    [[DBManager instance] save];
}

+ (DBFolder*)getFolderWithId:(NSString *)folderId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBFolder"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", folderId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBFolder*)results[0];
    return nil;
}


- (NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if(self.id) [dict setObject:self.id forKey:@"id"];
    if(self.object) [dict setObject:self.object forKey:@"object"];
    if(self.accountId) [dict setObject:self.accountId forKey:@"account_id"];
    if(self.name) [dict setObject:self.name forKey:@"name"];
    if(self.displayName) [dict setObject:self.displayName forKey:@"display_name"];
    if(self.unreads) [dict setObject:self.unreads forKey:@"unreads"];
    
    
    return dict;
}
@end
