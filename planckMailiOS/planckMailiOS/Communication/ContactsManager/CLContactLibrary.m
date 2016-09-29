//
//  CLContactLibrary.m
//
//
//  Created by Chirag Lakhani on 04/03/14.
//  Copyright (c) 2014 Chirag. All rights reserved.
//

#import "CLContactLibrary.h"
#import "UIImage+ImageSize.h"
#import "NSString+Utils.h"
#import "DBManager.h"
#import "Config.h"

#define kSAVED_CONTACTS_ARRAY_KEY @"contacts_array_key"

@implementation CLContactLibrary{
    NSMutableArray *contactDataArray;
}
@synthesize delegate;

static CLContactLibrary  *object;

+(CLContactLibrary *)sharedInstance{
    if(!object){
        object = [[CLContactLibrary alloc]init];
    }
    return  object;
}

-(void)getContactArrayForDelegate:(id<APContactLibraryDelegate>)aDelegate {
    self.delegate = aDelegate;
  
    [self fetchContactsWithCompletion:^(NSArray *data, NSError *error){
        if(error==nil)
        {            
            if([delegate respondsToSelector:@selector(apGetContactArray:)]) {
                [delegate apGetContactArray:[contactDataArray copy]];
            }
        }
    }];
}

- (void)getContactArray {
  [self getContactArrayForDelegate:self.delegate];
}

- (void)getContactArray:(void (^)(NSArray *data, NSError *error))completion
{
    [self fetchContactsWithCompletion:^(NSArray *data, NSError *error) {
        if(completion)
            completion(data, error);
    }];
}
- (void)getContactsNamesCount:(NSInteger)count offset:(NSInteger)offset forDelegate:(id<APContactLibraryDelegate>)aDelegate {
    self.delegate = aDelegate;
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    if(savedContacts) {
        [self parseContactsNamesCount:count offset:offset];
    } else {
        [self fetchContactsWithCompletion:^(NSArray *data, NSError *error){
            [self parseContactsNamesCount:count offset:offset];
        }];
    }
}

- (void)getPersonForContactNames:(NSDictionary *)names forDelegate:(id<APContactLibraryDelegate>)aDelegate {
    self.delegate = aDelegate;
    
    if(names) {
        NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
        if(savedContacts) {
            [self.delegate getPersonForNames:[self personForNames:names]];
        } else {
            [self fetchContactsWithCompletion:^(NSArray *data, NSError *error){
                [self.delegate getPersonForNames:[self personForNames:names]];
            }];
        }
    } else {
        [self.delegate getPersonForNames:nil];
    }
}

#pragma mark - Private methods

- (void)fetchContactsWithCompletion:(void(^)(NSArray *data, NSError *error))completion {
    contactDataArray = [[NSMutableArray alloc] init];
    [self fetchContacts:^(NSArray *contacts) {
        NSMutableArray *archivedPersons = [NSMutableArray new];
        
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ABRecordRef person = (__bridge ABRecordRef)obj;
            ABRecordID personId = ABRecordGetRecordID(person);
            
            CLPerson *people = [[CLPerson alloc]init];
            people.personID = [NSString stringWithFormat:@"phone-%d", personId];
            people.firstName = notEmptyStrValue((__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty));
            people.lastName = notEmptyStrValue((__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
            if (ABMultiValueGetCount(addressRef) > 0) {
                NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
                
                NSString *addressStr = [NSString stringWithFormat:@"%@ %@, %@ %@, %@",
                                        notEmptyStrValue([addressDict objectForKey:(NSString *)kABPersonAddressStreetKey]),
                                        notEmptyStrValue([addressDict objectForKey:(NSString *)kABPersonAddressCityKey]),
                                        notEmptyStrValue([addressDict objectForKey:(NSString *)kABPersonAddressStateKey]),
                                        notEmptyStrValue([addressDict objectForKey:(NSString *)kABPersonAddressZIPKey]),
                                        notEmptyStrValue([addressDict objectForKey:(NSString *)kABPersonAddressCountryCodeKey])];
                
                people.address = addressStr;
            }
            
            people.company = notEmptyStrValue((__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty));
            people.job = notEmptyStrValue((__bridge NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty));
            
            people.birthday = (__bridge NSDate *)ABRecordCopyValue(person, kABPersonBirthdayProperty);
                
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSInteger phonesCount = ABMultiValueGetCount(phoneNumbers);
            if (phonesCount > 0) {
                people.phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                
                //get array of phone numbers
                NSMutableArray *personsPhonnes = [NSMutableArray new];
                for(int i = 0; i < phonesCount; i++) {
                    NSMutableDictionary *personsPhonne = [NSMutableDictionary new];
                    //phone number
                    NSString *usersPhoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    if(usersPhoneNumber) {
                        [personsPhonne setObject:usersPhoneNumber forKey:PHONE_NUMBER];
                    }
                    //phone title
                    CFStringRef userPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
                    if(userPhoneLabel) {
                        NSString *phoneLabelLocalized = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(userPhoneLabel);
                        if(phoneLabelLocalized) {
                            [personsPhonne setObject:phoneLabelLocalized forKey:PHONE_TITLE];
                        }
                    }
                    [personsPhonnes addObject:personsPhonne];
                }
                people.phoneNumbers = personsPhonnes;
            } else {
                people.phoneNumber = @"None";
            }
            
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSInteger emailsCount = ABMultiValueGetCount(emails);
            
            
            if (emailsCount > 0) {
                people.email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
                
                
                //get array of phone numbers
                NSMutableArray *personEmails = [NSMutableArray new];
                for(int i = 0; i < emailsCount; i++) {
                    NSString *email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, i);
                    [personEmails addObject:email];
                    
                    //phone title
                    CFStringRef emailLabel = ABMultiValueCopyLabelAtIndex(emails, i);
                    if(emailLabel) {
                        NSString *emailLabelLocalized = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(emailLabel);
                        if(emailLabelLocalized) {
                            NSLog(@"%@", emailLabelLocalized);
                        }
                    }
                }
                people.emails = personEmails;
            } else {
                people.email = @"None";
            }
            
            NSData *personImageData = (__bridge NSData *)ABPersonCopyImageData(person);
            if(personImageData)
            {
                UIImage *personImage = [UIImage imageWithData:personImageData];
                people.personImage = personImage;
            }
            people.fullName = [NSString stringWithFormat:@"%@ %@", people.firstName, people.lastName];
            
            
            [DBSavedContact createOrUpdateContactWithCLPerson:people onContext:context];
            
            [archivedPersons addObject:[NSKeyedArchiver archivedDataWithRootObject:people]];
        }];
        
        [[DBManager instance] saveOnContext:context completion:^(NSError *error) {
            if(!error)
            {                
                [[DBManager instance] getSavedContactsWithTypeInBackground:CONTACT_TYPE_PHONE completion:^(NSArray *data) {
                    contactDataArray = [NSMutableArray arrayWithArray:data];
                    if(completion) {
                        completion(contactDataArray, nil);
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONE_CONTACT_UPDATED object:nil];
                }];
            }
        }];
        
        
        
        
        
//        NSMutableArray *newArchivedPersons = [NSMutableArray new];
//        for(int i = 0; i <=1 ; i++) {
//            for(NSData *person in archivedPersons) {
//                [newArchivedPersons addObject:[person copy]];
//            }
//        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:archivedPersons forKey:kSAVED_CONTACTS_ARRAY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
    } failure:^(NSError *error) {
        if(completion) {
            completion(nil, error);
        }
    }];
}

- (void)parseContactsNamesCount:(NSInteger)count offset:(NSInteger)offset {
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    NSMutableArray *personsArray = [NSMutableArray new];
    
    for(NSInteger i = offset; i < count + offset; i++) {
        if(i >= [savedContacts count]) {
            break;
        }
        NSData *archivedItem = savedContacts[i];
        
        CLPerson *person = [NSKeyedUnarchiver unarchiveObjectWithData:archivedItem];
        if(person) {
            NSDictionary *personNames = @{PERSON_NAME: person.firstName?:@"",
                                          PERSON_SECOND_NAME: person.lastName?:@""};
            [personsArray addObject:personNames];
        }
    }
    DLog(@"names count: %li", [personsArray count]);
    if([self.delegate respondsToSelector:@selector(getNamesOfContacts:)]) {
        [self.delegate getNamesOfContacts:personsArray];
    }
}

- (CLPerson *)personForNames:(NSDictionary *)names {
    CLPerson *person = nil;
    
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    for(NSData *savedPerson in savedContacts) {
        person = [NSKeyedUnarchiver unarchiveObjectWithData:savedPerson];
        
        if([person.firstName isEqualToString:names[PERSON_NAME]] &&
           [person.lastName isEqualToString:names[PERSON_SECOND_NAME]]) {
            if(person.personImage) {
                person.personImage = [[person.personImage getScaledImage] roundCorners];
            }
            
            break;
        }
    }
    
    return person;
}

#pragma mark - AddressBook Delegate Method

- (void)fetchContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure {
    if (ABAddressBookRequestAccessWithCompletion) {
        // on iOS 6
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
                if (!granted)
                    failure((__bridge NSError *)error);
                else
                    readAddressBookContacts(addressBook, success);
            //});
        });
       
    }
}
static void readAddressBookContacts(ABAddressBookRef addressBook, void (^completion)(NSArray *contacts)) {
    NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    completion(contacts);
}


-(void)createRandomAddressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // create 200 random contacts
    for (int i = 0; i < 2000; i++)
    {
        // create an ABRecordRef
        ABRecordRef record = ABPersonCreate();
        
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABStringPropertyType);
        
        NSString *email = [NSString stringWithFormat:@"%i@%ifoo.com", i, i];
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(email), kABHomeLabel, NULL);
        
        NSString *fname = [NSString stringWithFormat:@"Name %i", i];
        NSString *lname = [NSString stringWithFormat:@"Last %i", i];
        
        // add the first name
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)(fname), NULL);
        
        // add the last name
        ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(lname), NULL);
        
        // add the home email
        ABRecordSetValue(record, kABPersonEmailProperty, multi, NULL);
        
        
        // add the record
        ABAddressBookAddRecord(addressBook, record, NULL);
    }
    
    // save the address book
    ABAddressBookSave(addressBook, NULL);
    
    // release
    CFRelease(addressBook);
}
@end
