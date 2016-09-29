//
//  WKEmailListController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailListController.h"
#import "WKEmailRow.h"
#import "PMThread.h"
#import "WKEmailController.h"
#import "PMTypeContainer.h"
#import "WatchKitDefines.h"

#define LOAD_MORE_ROW_TYPE @"loadMoreType"

@interface WKEmailListController () {
    NSInteger emailsOffset;
}

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (nonatomic, strong) NSMutableArray *emailsDictionaries;

@property (nonatomic, strong) PMTypeContainer *selectedAccount;

@end

@implementation WKEmailListController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if(context[TITLE]) {
        [self setTitle:context[TITLE]];
    }
    
    if(context[CONTENT]) {
        if ([WCSession isSupported]) {
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
            
            [self showActivityIndicator:YES];
            
            if([context[CONTENT] isKindOfClass:[PMThread class]]) {
                __weak typeof(self) __self = self;
                
                PMThread *inboxModel = (PMThread *)context[CONTENT];
                NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:inboxModel];
                [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE:@(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO:emailData} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    
                    @autoreleasepool {
                        inboxModel.isUnread = NO;
                        
                        if([replyMessage isKindOfClass:[NSArray class]]) {
                            __self.dataSource = [NSMutableArray new];
                            __self.emailsDictionaries = [NSMutableArray new];
                            for(NSDictionary *item in replyMessage) {
                                PMThread *lNewItem = [PMThread new];
                                lNewItem.snippet = item[@"snippet"];
                                lNewItem.subject = item[@"subject"];
                                lNewItem.accountId = item[@"account_id"];
                                lNewItem.id = item[@"id"];
                                lNewItem.version = 1;
                                lNewItem.ownerName = [item[@"from"] firstObject][@"name"];
                                lNewItem.isUnread = NO;
                                NSTimeInterval lastTimeStamp = [item[@"date"] doubleValue];
                                lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
                                
                                [__self.dataSource addObject:lNewItem];
                                [__self.emailsDictionaries addObject:item];
                                
                                [__self reloadTableView];
                                [__self showActivityIndicator:NO];
                            }
                        }
                    }
                    
                } errorHandler:^(NSError * _Nonnull error) {
                    
                }];
                
                
            } else {
                _selectedAccount = context[CONTENT];
                _dataSource = [NSMutableArray new];
                [self loadEmails];
            }
        }
        
    }
}

#pragma mark - Table view methods

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    PMThread *email = _dataSource[rowIndex];
    if(email.isLoadMore) {
        WKEmailRow *row = [self.tableView rowControllerAtIndex:rowIndex];
        [row showActivityIndicator:YES];
        
        emailsOffset += 10;
        
        [self loadEmails];
    } else {
        if(email.version > 1) {
            [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: email.subject, CONTENT: email}];
        } else {
            NSDictionary *context = nil;
            if([_emailsDictionaries count] > rowIndex) {
                context = @{CONTENT: email, ADDITIONAL_INFO: _emailsDictionaries[rowIndex]};
            } else {
                context = @{CONTENT: email};
            }
            [self pushControllerWithName:EMAIL_CONTROLLER_IDENTIFIER context:context];
        }
    }
}

- (void)reloadTableView {
    [self.tableView setNumberOfRows:[_dataSource count] withRowType:EMAIL_ROW_IDENTIFIER];
    
    [self updateRows];
}

- (void)updateRows {
    NSInteger i = 0;
    for(PMThread *container in _dataSource) {
        WKEmailRow *row = [self.tableView rowControllerAtIndex:i++];
        [row setEmailContainer:container];
    }
}

#pragma mark - Load emails

- (void)loadEmails {
    __weak typeof(self) __self = self;
    
    NSData *account = [NSKeyedArchiver archivedDataWithRootObject:_selectedAccount];
    [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmails), WK_REQUEST_INFO: account, WK_REQUEST_EMAILS_LIMIT: @(emailsOffset)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        if(replyMessage[WK_REQUEST_RESPONSE]) {
            NSArray *archivedMessages = replyMessage[WK_REQUEST_RESPONSE];
            
            PMThread *loadMoreModel = [__self.dataSource lastObject];
            if(loadMoreModel.isLoadMore) {
                [__self.dataSource removeLastObject];
            }
            for(NSData *message in archivedMessages) {
                [__self.dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:message]];
            }
            if([archivedMessages count] == EMAILS_LIMIT_COUNT) {
                if(!loadMoreModel) {
                    loadMoreModel = [PMThread new];
                    loadMoreModel.ownerName = @"Load More";
                    loadMoreModel.isLoadMore = YES;
                }
                [__self.dataSource addObject:loadMoreModel];
            }
            
            [__self reloadTableView];
            
            [__self showActivityIndicator:NO];
        }
        
    } errorHandler:^(NSError * _Nonnull error) {
        
    }];
    
    
}

- (void)willActivate {
    [super willActivate];
    
    
    
    [self updateRows];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



