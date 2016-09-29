//
//  DBSavedContact.m
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "DBSavedContact.h"
#import "DBManager.h"
#import "Config.h"

#define DB_SAVED_CONTACT @"DBSavedContact"
@implementation DBSavedContact

// Insert code here to add functionality to your managed object subclass
+ (DBSavedContact*)createOrUpdateContactWithData:(NSDictionary*)data onContext:(nonnull NSManagedObjectContext *)context
{
    
    NSString *contactId = data[@"id"];
    
    DBSavedContact *contact;
    
    if(contactId)
        contact = [DBSavedContact getContactWithId:contactId onContext:context];
    
    BOOL isCreate = NO;
    if(!contact)
    {
        contact = (DBSavedContact *)[NSEntityDescription insertNewObjectForEntityForName:DB_SAVED_CONTACT inManagedObjectContext:context];
        isCreate = YES;
    }
    
    if(!contactId)
    {
        contactId = [NSString stringWithFormat:@"email-%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    
    contact.id = contactId;
    NSString *name = notNullStrValue(data[@"name"]);
    if(name) name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    contact.name = name;
    contact.address = notNullStrValue(data[@"address"]);
    contact.company = notNullStrValue(data[@"company"]);
    contact.job = notNullStrValue(data[@"job"]);
    contact.ringtone = notNullStrValue(data[@"ringtone"]);
    contact.birthday = data[@"birthday"];
    
    if(isCreate)
        contact.createdTime = [NSDate date];
    contact.modifiedTime = [NSDate date];
    
    
    if(data[@"phone_numbers"])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data[@"phone_numbers"]
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        contact.phoneNumbers = jsonString;
    }
    
    
    if(data[@"emails"])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data[@"emails"]
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        contact.emails = jsonString;
    }
    
    contact.profileData = data[@"profile_data"];
    
    return contact;
}


+ (DBSavedContact*)createOrUpdateContactWithCLPerson:(CLPerson *)person onContext:(NSManagedObjectContext*)context
{
    NSData *profileImageData = nil;
    if(person.personImage)
        profileImageData = UIImagePNGRepresentation(person.personImage);
    
    NSMutableDictionary *item = [NSMutableDictionary new];
    [item setObject:person.personID forKey:@"id"];
    [item setObject:person.fullName forKey:@"name"];
    if(person.address) [item setObject:person.address forKey:@"address"];
    if(person.company) [item setObject:person.company forKey:@"company"];
    if(person.job) [item setObject:person.job forKey:@"job"];
    if(person.birthday) [item setObject:person.birthday forKey:@"birthday"];
    if(person.email) [item setObject:person.email forKey:@"email"];
    if(person.emails && person.emails.count) [item setObject:person.emails forKey:@"emails"];
    if(person.phoneNumber) [item setObject:person.phoneNumber forKey:@"phone_number"];
    if(person.phoneNumbers && person.phoneNumbers.count) [item setObject:person.phoneNumbers forKey:@"phone_numbers"];
    if(profileImageData) [item setObject:profileImageData forKey:@"profile_data"];
    
    return [DBSavedContact createOrUpdateContactWithData:item onContext:context];
}

+ (DBSavedContact*)getContactWithId:(NSString*)contactId
{    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_SAVED_CONTACT];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", contactId]];
    
    NSError *error;
    NSArray *results = [[DBManager instance].mainContext executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBSavedContact*)results[0];
    return nil;
}
+ (DBSavedContact*)getContactWithId:(NSString*)contactId onContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_SAVED_CONTACT];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", contactId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBSavedContact*)results[0];
    return nil;
}

+ (DBSavedContact *)getContactWithEmail:(NSString *)email {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_SAVED_CONTACT];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"emails CONTAINS[cd] %@", email]];
    
    NSError *error;
    NSArray *results = [dbManager.mainContext executeFetchRequest:request error:&error];
    
    if(!error)
    {
        for(DBSavedContact *contact in results)
        {
            NSDictionary *contactDict = [contact convertToDictionary];
            for(NSString *emailAddress in contactDict[@"emails"])
            {
                if([email isEqualToString:emailAddress])
                    return contact;
            }
        }
    }
    
    return nil;
}

+ (void)getContactsWithEmailsInBackground:(NSArray *)emails completion:(void (^)(NSArray *contacts))handler
{
    if(!emails || emails.count==0)
    {
        if(handler) handler(nil);
        return;
    }
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_SAVED_CONTACT];
    
    NSMutableArray *predicates = [NSMutableArray new];
    for(NSString *email in emails)
    {
        [predicates addObject:[NSPredicate predicateWithFormat:@"emails CONTAINS[cd] %@", email]];
    }
    [request setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:predicates]];
    
    NSManagedObjectContext *context = [dbManager workerContext];
    
    [context performBlock:^{
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        if(results && results.count)
        {
            [dbManager.mainContext performBlock:^{
                
                NSMutableArray *contacts = [NSMutableArray new];
                for(NSManagedObject *obj in results)
                {
                    DBSavedContact *contact = [dbManager.mainContext objectWithID:obj.objectID];
                    [contacts addObject:contact];
                }
                if(handler) handler(contacts);
            }];
        }
        else
        {
            if(handler)
                handler(nil);
        }
        
        
    }];
    
}
-(NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:self.id forKey:@"id"];
    [dict setObject:self.name forKey:@"name"];
    if(self.address) [dict setObject:self.address forKey:@"address"];
    if(self.company) [dict setObject:self.company forKey:@"company"];
    if(self.job) [dict setObject:self.job forKey:@"job"];
    if(self.ringtone) [dict setObject:self.ringtone forKey:@"ringtone"];
    if(self.birthday) [dict setObject:self.birthday forKey:@"birthday"];
    [dict setObject:self.createdTime forKey:@"createdTime"];
    [dict setObject:self.modifiedTime forKey:@"modifiedTime"];
    
    if(self.phoneNumbers && self.phoneNumbers.length>0)
    {        
        NSData *jsonData = [self.phoneNumbers dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *phoneNumbers = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
            [dict setObject:phoneNumbers forKey:@"phone_numbers"];
        }
    }
    
    if(self.emails && self.emails.length>0)
    {
        NSLog(@"Saved Contact Emails = %@", self.emails);
        NSData *jsonData = [self.emails dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *emails = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
            [dict setObject:emails forKey:@"emails"];
        }
    }
    
    if(self.profileData) [dict setObject:self.profileData forKey:@"profile_data"];
    
    return dict;
    
}

-(NSString*)getTitle
{
    if(self.name && self.name.length && ![self.name isEqual:[NSNull null]]) return self.name;
    
    return [self getFirstEmailAddress];
}

-(NSString*)getTitle:(NSString *)email
{
    if(self.name && self.name.length) return self.name;
    return email;
}
-(NSString*)getJobTitle
{
    NSMutableString *jobTitle = [NSMutableString new];
    
    if(self.job && self.job.length) [jobTitle appendString:self.job];
    if(self.company && self.company.length)
    {
        if(jobTitle.length) [jobTitle appendString:@", "];
        [jobTitle appendString:self.company];
    }
    
    return jobTitle;
}
-(NSArray*)getEmailArray
{
    if(self.emails && self.emails.length>0)
    {
        NSLog(@"Saved Contact Emails = %@", self.emails);
        NSData *jsonData = [self.emails dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *emails = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:nil];
            return emails;
        }
    }
    return nil;
}
-(NSArray*)getPhoneArray
{
    if(self.phoneNumbers && self.phoneNumbers.length>0)
    {
        NSData *jsonData = [self.phoneNumbers dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *phoneNumbers = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
            return phoneNumbers;
        }
    }
    
    return nil;
}

-(NSString*)getFirstEmailAddress
{
    NSArray *emails = [self getEmailArray];
    if(!emails || emails.count==0) return @"";
    
    return notEmptyStrValue(emails[0]);
}

-(void)addEmail:(NSString *)email
{
    NSArray *emails = [self getEmailArray];
    NSMutableArray *contactEmails = emails&&emails.count?[NSMutableArray arrayWithArray:emails]:[NSMutableArray new];
    
    if(![contactEmails containsObject:email])
    {
        [contactEmails addObject:email];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactEmails
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.emails = jsonString;
    }
}

- (NSString*)getContactType
{
    return [self.id componentsSeparatedByString:@"-"][0];
}
- (NSInteger)getContactTypeValue
{
    NSInteger type;
    
    if([self.id containsString:CONTACT_TYPE_EMAIL]) type = 1;
    else if([self.id containsString:CONTACT_TYPE_PHONE]) type = 2;
    else if([self.id containsString:CONTACT_TYPE_SALESFORCE]) type = 3;
    
    return type;
}
#pragma mark NSSecureCoding delegate implementation

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.company forKey:@"company"];
    [aCoder encodeObject:self.job forKey:@"job"];
    [aCoder encodeObject:self.ringtone forKey:@"ringtone"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.phoneNumbers forKey:@"phone_numbers"];
    [aCoder encodeObject:self.emails forKey:@"emails"];
    [aCoder encodeObject:self.profileData forKey:@"profile_data"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    DBSavedContact *contact = [DBSavedContact new];
    
    contact.id = [aDecoder decodeObjectForKey:@"id"];
    contact.name = [aDecoder decodeObjectForKey:@"name"];
    contact.address = [aDecoder decodeObjectForKey:@"address"];
    contact.company = [aDecoder decodeObjectForKey:@"company"];
    contact.job = [aDecoder decodeObjectForKey:@"job"];
    contact.ringtone = [aDecoder decodeObjectForKey:@"ringtone"];
    contact.birthday = [aDecoder decodeObjectForKey:@"birthday"];
    contact.phoneNumbers = [aDecoder decodeObjectForKey:@"phone_numbers"];
    contact.emails = [aDecoder decodeObjectForKey:@"emails"];
    contact.profileData = [aDecoder decodeObjectForKey:@"profile_data"];
    
    return contact;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
@end
