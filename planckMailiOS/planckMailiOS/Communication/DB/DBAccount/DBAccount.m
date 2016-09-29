//
//  DBAccount.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBAccount.h"
#import "DBManager.h"
#import "Config.h"

@implementation DBAccount


+(DBAccount*)createOrUpdateAccountWithData:(NSDictionary*)data {
    
    DBManager *dbManager = [DBManager instance];
    NSManagedObjectContext *context = [dbManager mainContext];
    
    DBAccount *account;
    
    NSString *accountId = data[@"account_id"];
    
    if(accountId && accountId.length)
        account = [DBAccount getAccountWithAccountId:accountId context:context];
    else
    {
        NSString *email = data[@"email"];
        NSString *type = data[@"type"];
        NSString *provider = data[@"provider"];
        
        account = [DBAccount getAccountWithEmail:email type:type provider:provider context:context];
    }
    
    if(!account)
        account = (DBAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"DBAccount" inManagedObjectContext:context];
    
    account.title = data[@"title"];
    account.email = data[@"email"];
    account.descript = data[@"description"];
    account.type = data[@"type"];
    account.provider = data[@"provider"];
    account.token = data[@"token"];
    account.accountId = accountId;
    
    [dbManager save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUNT_CHANGED object:nil];
    return account;
}
+(DBAccount*)createOrUpdateAccountWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context
{
    
    DBManager *dbManager = [DBManager instance];
    
    DBAccount *account;
    
    NSString *accountId = data[@"account_id"];
    
    if(accountId && accountId.length)
        account = [DBAccount getAccountWithAccountId:accountId context:context];
    else
    {
        NSString *email = data[@"email"];
        NSString *type = data[@"type"];
        NSString *provider = data[@"provider"];
        
        account = [DBAccount getAccountWithEmail:email type:type provider:provider context:context];
    }
    
    if(!account)
        account = (DBAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"DBAccount" inManagedObjectContext:context];
    
    account.title = data[@"title"];
    account.email = data[@"email"];
    account.descript = data[@"description"];
    account.type = data[@"type"];
    account.provider = data[@"provider"];
    account.token = data[@"token"];
    account.accountId = accountId;
    
    return account;
}

+ (DBAccount *)getAccountWithAccountId:(NSString *)accountId
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBAccount"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"accountId == %@", accountId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBAccount*)results[0];
    return nil;
}
+ (DBAccount *)getAccountWithEmail:(NSString *)email type:(NSString*)type provider:(NSString*)provider
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBAccount"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"email == %@ AND type == %@ AND provider == %@", email, type, provider]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBAccount*)results[0];
    return nil;
}

+ (DBAccount *)getAccountWithProvider:(NSString*)provider
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBAccount"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"provider == %@", provider]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBAccount*)results[0];
    return nil;
}

+ (DBAccount *)getAccountWithAccountId:(NSString *)accountId context:(NSManagedObjectContext*)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBAccount"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"accountId == %@", accountId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBAccount*)results[0];
    return nil;
}
+ (DBAccount *)getAccountWithEmail:(NSString *)email type:(NSString*)type provider:(NSString*)provider context:(nonnull NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBAccount"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"email == %@ AND type == %@ AND provider == %@", email, type, provider]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBAccount*)results[0];
    return nil;
}
+ (void)deleteAccount:(DBAccount*)account
{
    [[DBManager instance].mainContext deleteObject:account];
    [[DBManager instance] save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUNT_CHANGED object:nil];
}
-(NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    
    [dict setObject:self.id forKey:@"id"];
    [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.email forKey:@"email"];
    [dict setObject:self.descript forKey:@"desctiption"];
    [dict setObject:self.type forKey:@"type"];
    [dict setObject:self.provider forKey:@"provider"];
    [dict setObject:self.token?self.token:@"" forKey:@"token"];
    
    return dict;
}


@end
