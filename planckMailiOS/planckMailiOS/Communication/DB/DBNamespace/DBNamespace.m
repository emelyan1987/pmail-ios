//
//  DBNamespace.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "DBNamespace.h"
#import "DBManager.h"

@implementation DBNamespace

@dynamic id;
@dynamic object;
@dynamic namespace_id;
@dynamic account_id;
@dynamic email_address;
@dynamic name;
@dynamic provider;
@dynamic token;
@dynamic unreadCount;
@dynamic organizationUnit;


+ (DBNamespace *)getNamespaceWithAccountId:(NSString *)accountId
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBNamespace"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"account_id == %@", accountId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBNamespace*)results[0];
    return nil;
}

+ (DBNamespace *)getNamespaceWithToken:(NSString *)token
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBNamespace"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"token == %@", token]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBNamespace*)results[0];
    return nil;
}

+ (DBNamespace *)getNamespaceWithEmail:(NSString *)email
{
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBNamespace"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"email_address == %@", email]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBNamespace*)results[0];
    return nil;
}
@end
