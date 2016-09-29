 //
//  WKContactsController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactsController.h"
#import "ExtensionDelegate.h"
#import "WKContactInfoController.h"
#import "WKContactRow.h"
#import "WatchKitDefines.h"
#import "CLPerson.h"

#define CONTACT_ROW_IDENT @"contactRow"

@interface WKContactsController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *noContactsLabel;

@property (nonatomic, assign) BOOL isLoadingContacts;
@property (nonatomic, assign) NSInteger contactsOffset;

@property (nonatomic, strong) WCSession *session;
@end

@implementation WKContactsController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    _dataSource = [[NSUserDefaults standardUserDefaults] objectForKey:@"contact_data"];
    if(!_dataSource) _dataSource = [NSMutableArray new];
    [self updateTableView];
    
    _contactsOffset = 0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveContactList:) name:WK_NOTIFICATION_DID_RECEIVE_CONTACT_LIST object:nil];
    
    
    
    self.session = [ExtensionDelegate sharedInstance].session;
}

- (void)willActivate {
    [super willActivate];
    
    //[self loadContacts];
}

- (void)didDeactivate {
    [super didDeactivate];
}
- (void)loadContacts
{
    [self.session sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetContacts)} replyHandler:nil errorHandler:nil];
}
- (void)loadContactFromPhone {
    _isLoadingContacts = YES;
    [self showActivityIndicatorAndTable:YES];
    
    
    __weak WKContactsController *weakSelf = self;
    

    [self.session sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetContacts)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
        @autoreleasepool {
            NSArray *responceArray = replyMessage[WK_REQUEST_RESPONSE];
            if(responceArray) {
                if([responceArray isKindOfClass:[NSArray class]] && [responceArray count] > 0) {
                    weakSelf.contactsOffset += [responceArray count];
//                    for(NSData *person in responceArray) {
//                        [weakSelf.dataSource addObject:person];
//                    }
                    weakSelf.dataSource = [NSMutableArray arrayWithArray:responceArray];
                    [weakSelf showNoContacts:NO withInfo:nil];
                } else if([weakSelf.dataSource count] == 0) {
                    [weakSelf showNoContacts:YES withInfo:@"You haven't any contact"];
                }
            } else if([weakSelf.dataSource count] == 0) {
                [weakSelf showNoContacts:YES withInfo:@"Can't get contacts"];
            }
            
            [weakSelf updateTableView];
//            if([responceArray count] >= CONTACTS_LIMIT_COUNT) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [__self loadNextContacts];
//                });
//                [__self showActivityIndicatorAndTable:YES];
//            } else {
//                __self.isLoadingContacts = NO;
//                [__self showActivityIndicatorAndTable:NO];
//            }
            
            weakSelf.isLoadingContacts = NO;
            [weakSelf showActivityIndicatorAndTable:NO];
        }
        
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"PMWatchRequestGetContacts error=%@", error);
        
        _isLoadingContacts = NO;
        [weakSelf showActivityIndicatorAndTable:NO];
    }];
}

- (void)showNoContacts:(BOOL)noContacts withInfo:(NSString *)info {
  [self.tableView setHidden:noContacts];
  [self.noContactsLabel setHidden:!noContacts];
  if(info) {
    [self.noContactsLabel setText:info];
  }
}



#pragma mark - Table view methods

- (void)updateTableView {
  [self.tableView setNumberOfRows:[_dataSource count] withRowType:CONTACT_ROW_IDENT];
  
  NSInteger i = 0;
  for(NSDictionary *person in _dataSource) {
    WKContactRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setContactName:person[@"name"]];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSDictionary *contactData = _dataSource[rowIndex];
    NSString *contactId = contactData[@"id"];
    [self pushControllerWithName:CONTACTS_INFO_IDENT context:contactId];
}

#pragma mark - Help methods

- (void)showActivityIndicatorAndTable:(BOOL)yesOrNo {
    [super showActivityIndicator:yesOrNo];
//    [self.tableView setHidden:yesOrNo];
}


-(void)didReceiveContactList:(NSNotification*)notification
{
    _dataSource = [[NSUserDefaults standardUserDefaults] objectForKey:WK_CONTACT_LIST];
    [self updateTableView];
}
@end



