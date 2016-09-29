//
//  CLContactLibrary.h
//
//  Created by Chirag Lakhani on 04/03/14.
//  Copyright (c) 2014 Chirag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABMultiValue.h>
#import "CLPerson.h"
#import "DBSavedContact.h"

@protocol APContactLibraryDelegate;

@protocol APContactLibraryDelegate <NSObject>

- (void)apGetContactArray:(NSArray *)contactArray;

@optional

- (void)getNamesOfContacts:(NSArray *)contactsNames;
- (void)getPersonForNames:(CLPerson *)person;
- (BOOL)shouldScaleImage;

@end

@interface CLContactLibrary : NSObject


@property(nonatomic,weak)id <APContactLibraryDelegate> delegate;

- (void)getContactArray;
- (void)getContactArrayForDelegate:(id<APContactLibraryDelegate>)aDelegate;
- (void)getContactsNamesCount:(NSInteger)count offset:(NSInteger)offset forDelegate:(id<APContactLibraryDelegate>)aDelegate;
- (void)getPersonForContactNames:(NSDictionary *)names forDelegate:(id<APContactLibraryDelegate>)aDelegate;
- (void)getContactArray:(void(^)(NSArray *data, NSError *error))completion;
+ (CLContactLibrary *)sharedInstance;

- (void)createRandomAddressBook;
@end
