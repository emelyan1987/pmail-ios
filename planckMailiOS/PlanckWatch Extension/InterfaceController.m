//
//  InterfaceController.m
//  planckMailiOS WatchKit Extension
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "InterfaceController.h"
#import "ExtensionDelegate.h"
#import "WKPlainRow.h"
#import "PMTypeContainer.h"
#import "PMEmailContainer.h"
#import "WKEmailListController.h"
#import "WatchKitDefines.h"
#import "WKContactsController.h"
#import "WKCalendarController.h"

@import WatchConnectivity;

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *addAccountButton;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *appLogoView;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *accountsArray;
@property (assign, nonatomic) NSInteger allUnreadCount;

@property (nonatomic, strong) WCSession *session;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.addAccountButton setHidden:YES];
    [self.tableView setHidden:YES];
    
    [self setHelpItemsHidden:NO];
    
    [self setTitle:@"PlanckLabs"];
    
    self.session = [ExtensionDelegate sharedInstance].session;
}

- (void)willActivate {
    [super willActivate];
    
    if ([self.session isReachable]) {
        [self performSelector:@selector(updateUserAccounts) withObject:nil afterDelay:0.1];
    }
}

- (void)updateUserAccounts {
    [self showActivityIndicator:YES];
    __weak typeof(self) weakSelf = self;
    

        
        [self.session sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestAccounts)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            [weakSelf showActivityIndicator:NO];
            
            //get requested accounts
            NSArray *accounts = replyMessage[WK_REQUEST_RESPONSE];
            if([accounts count] > 0) {
                NSMutableArray *tempAccounts = [NSMutableArray new];
                for(NSData *arcObj in accounts) {
                    PMTypeContainer *myObject = [NSKeyedUnarchiver unarchiveObjectWithData:arcObj];
                    [tempAccounts addObject:myObject];
                }
                
                if(![weakSelf.accountsArray isEqualToArray:tempAccounts]) {
                    weakSelf.accountsArray = [NSMutableArray arrayWithArray:tempAccounts];
                    
                    weakSelf.dataSource = [NSMutableArray arrayWithArray:@[//[PMTypeContainer initWithTitle:@"All Unread" count:-1],
                                                                         [PMTypeContainer initWithTitle:@"Calendar" count:-1],
                                                                         [PMTypeContainer initWithTitle:@"Contact" count:-1]]];
                    [weakSelf.dataSource insertObjects:weakSelf.accountsArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [weakSelf.accountsArray count])]];
                    [weakSelf reloadTable];
                }
                
                //[weakSelf updateAccountsUnreadCount];
            }
            
            [weakSelf.tableView setHidden:[accounts count] == 0];
            [weakSelf.addAccountButton setHidden:[accounts count] != 0];
            
            [weakSelf.appLogoView setHidden:YES];

            
        } errorHandler:^(NSError * _Nonnull error) {
            [weakSelf showActivityIndicator:NO];
            NSLog(@"error %@",[error localizedDescription]);
        }];
        
    
    }

- (void)setHelpItemsHidden:(BOOL)hidden {
    //[self showActivityIndicator:!hidden];
    [self.appLogoView setHidden:hidden];
}

- (void)reloadTable {
    [self.tableView setNumberOfRows:[_dataSource count] withRowType:PLAIN_ROW_IDENTIFIER];
    [self updateRows];
}

- (void)updateRows {
    NSInteger i = 0;
    for(PMTypeContainer *type in _dataSource) {
        WKPlainRow *row = [self.tableView rowControllerAtIndex:i++];
        [row setTypeContainer:type];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    PMTypeContainer *selectedType = _dataSource[rowIndex];
    
    if(selectedType.isNameSpace) {
        [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: selectedType.email_address, CONTENT: selectedType}];
    } else if (rowIndex == [_dataSource count] - 1) {
        [self pushControllerWithName:CONTACTS_LIST_IDENT context:nil];
    }else if (rowIndex == [_dataSource count] -2) {
        [self pushControllerWithName:CALENDAR_IDENT context:nil];
    }
}

- (IBAction)addAccountPressed {
    [self updateUserActivity:@"com.planckMailiOS.addAccount" userInfo:@{@"info": @"its ok"} webpageURL:nil];
}



- (void)updateAccountsUnreadCount {
    if([_accountsArray count] > 0 && _dataSource) {
        _allUnreadCount = 0;
        
        NSMutableArray *copyAccounts = [_accountsArray mutableCopy];
        [self updateUnreadCountForAccounts:copyAccounts];
    }
}

- (void)updateUnreadCountForAccounts:(NSMutableArray *)accounts {
    if([accounts count] > 0)  {
        
        //[self showActivityIndicator:YES];
        
        __block PMTypeContainer *account = [accounts firstObject];
        NSString *token = account.token;
        
        __weak InterfaceController *weakSelf = self;
        if(token)
            [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetUnreadEmailsCount), WK_REQUEST_INFO: token} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                
                //[weakSelf showActivityIndicator:NO];
                
                NSInteger count = [replyMessage[WK_REQUEST_RESPONSE] integerValue];
                    account.unreadCount = count;
                    weakSelf.allUnreadCount += count;
                    
                    //update All unread number
                    //          __block PMTypeContainer *allUnreadAccount = [__self.dataSource firstObject];
                    //          allUnreadAccount.unreadCount = __self.allUnreadCount;
                    
                    [accounts removeObjectAtIndex:0];
                    if([accounts count] > 0) {
                        [weakSelf updateUnreadCountForAccounts:accounts];
                    }
                    
                    [weakSelf updateRows];
                
            } errorHandler:^(NSError * _Nonnull error) {
                //[weakSelf showActivityIndicator:NO];
            }];
        
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


#pragma mark - Local notification handler

- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
    
    if ([identifier isEqualToString:@"respomd"]) {
        NSLog(@"lol");
    }
}


@end



