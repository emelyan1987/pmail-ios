//
//  DBContact.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/16/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBContact.h"
#import "DBNamespace.h"
#import "DBManager.h"

#define DB_CONTACT @"DBContact"
@implementation DBContact

// Insert code here to add functionality to your managed object subclass

+ (DBContact*)createOrUpdateContactWithData:(NSDictionary*)data onContext:(nonnull NSManagedObjectContext *)context
{
    
    NSString *email = data[@"email"];
    
    DBContact *dbContact = [DBContact getContactWithEmail:email context:context];
    
    if(!dbContact)
        dbContact = (DBContact *)[NSEntityDescription insertNewObjectForEntityForName:DB_CONTACT inManagedObjectContext:context];
    
    if(data[@"account_id"])
        dbContact.account_id = data[@"account_id"];
    dbContact.name = notNullStrValue(data[@"name"]);
    dbContact.email = notNullStrValue(data[@"email"]);
    
    if(data[@"phone_numbers"])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data[@"phone_numbers"]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        dbContact.phone_numbers = jsonString;
    }
    return dbContact;
}

+ (DBContact *)getContactWithEmail:(NSString *)email {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CONTACT];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"email == %@", email]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBContact*)results[0];
    return nil;
}
+ (DBContact *)getContactWithEmail:(NSString *)email context:(NSManagedObjectContext*)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CONTACT];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"email == %@", email]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBContact*)results[0];
    return nil;
}

-(NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.email forKey:@"email"];
    [dict setObject:self.account_id forKey:@"account_id"];
    
    if(self.phone_numbers && self.phone_numbers.length>0)
    {
        
        NSData *jsonData = [self.phone_numbers dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *phoneNumbers = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];            
            [dict setObject:phoneNumbers forKey:@"phone_numbers"];
        }
    }
    
    return dict;
    
}
@end
