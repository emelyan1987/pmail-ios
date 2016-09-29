//
//  PMMessagesTableView.h
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMThread.h"

@class PMMessagesTableView;
@protocol PMMessagesTableViewDelegate <NSObject>
@required
- (NSArray *)PMMessagesTableViewDelegateGetData:(PMMessagesTableView*)messagesTableView;
- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView*)messagesTableVie;
- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView*)messagesTableVie nextPage:(BOOL)nextPage;
- (void)PMMessagesTableViewDelegate:(PMMessagesTableView*)messagesTableView selectedMessage:(PMThread*)messageModel selectedMessageArray:(NSArray*)messageArray;
- (void)PMMessagesTableViewDelegateShowAlert:(PMMessagesTableView *)messagesTableView inboxMailModel:(PMThread*)mailModel showAutoAsk:(BOOL)autoAsk;


- (selectedMessages)getMessagesType;

- (void)didTapRSVPButton:(id)sender model:(PMThread*)model;
- (void)didTapUnsubscribeButton:(id)sender model:(PMThread*)model;
- (void)didThreadArchived:(PMThread*)thread;
@end

@interface PMMessagesTableView : UIView 
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, weak) id<PMMessagesTableViewDelegate> delegate;
@property(nonatomic, strong) PMThread *inboxMailModel;

- (void)initializeMessageTableView;
- (void)reloadMessagesTableView;
- (void)filterMessagesWithType:(NSString *)type;
- (void)clearFilter;

- (void)removeInboxMailModel:(PMThread*)model;
@end
