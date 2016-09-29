//
//  PMMessagesTableView.m
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMessagesTableView.h"
#import "PMMailTVCell.h"
#import "PMLoadMoreTVCell.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "PMAPIManager.h"
#import "Config.h"
#import "PMTextManager.h"
#import "FTWCache.h"
#import "PMMailFilterCell.h"
#import "PMArchivedMailUndoCell.h"
#import "AlertManager.h"
#import "PMThread+Extended.h"
#import "PMScheduleManager.h"

#define NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED @"notification_mail_additional_info_updated"

#define SCHEDULED_SECTIONS @[@"Later Today", @"This Evening", @"Tomorrow", @"This Weekend", @"Next Week", @"In a Month", @"Someday", @"Pick a Date"]
#define LIMIT 50


@class PMSnoozeAlertViewController;

@interface PMMessagesTableView () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, PMMailTVCellDelegate> {
    NSMutableArray *_itemMailArray;
    NSMutableArray *filteredMailArray;
    NSMutableDictionary *_scheduledMailsDictionary;
    
    NSMutableArray *_sectionTitles;
    
    NSMutableArray *_archivedMails;
    
    NSMutableDictionary *_eventInfos;   // The event information for mail thread(NSDictionary)
    NSMutableDictionary *_salesforces;  // The data for presenting whether mail comes from salesforce email(BOOL)
    
    selectedMessages _selectedTableType;
    UIAlertView * _alertView;
    
    NSMutableDictionary *keyphrasesArray;
    
    BOOL isFilter;
    NSString *filterName;
    
    NSMutableDictionary *loadMoreFlags;
    NSMutableDictionary *heightForRows;
    
    UIRefreshControl *refreshControl;
}

@end

@implementation PMMessagesTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _itemMailArray = [NSMutableArray array];
    _scheduledMailsDictionary = [NSMutableDictionary dictionary];
    _sectionTitles = [NSMutableArray array];
    
    [self getSelectedTableType];
    
    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PMLoadMoreTVCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"loadMoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PMMailTVCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"mailCell"];
    
    
    keyphrasesArray = [[NSMutableDictionary alloc] init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    

    // Set inbox mail model change notification listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationMessageUpdated:) name:NOTIFICATION_MESSAGE_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationMailAdditionalInfoUpdated:) name:NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED object:nil];
}

-(void)handleRefresh:(id)sender
{
    if(loadMoreFlags)
        [loadMoreFlags removeAllObjects];
    
    [self updateMails];
    [refreshControl endRefreshing];
}

#pragma mark - UITableView delegate
#pragma mark - UITableView data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_selectedTableType == ReadLaterMessagesSelected)
        return 115;
    PMThread *model;
    if(_selectedTableType == FollowUpsMessagesSelected)
    {
        model = _scheduledMailsDictionary[_sectionTitles[indexPath.section]][indexPath.row];
    }
    else
    {
        if(isFilter)
            model = filteredMailArray[indexPath.row];
        else
            model = _itemMailArray[indexPath.row];
    }
    
    if(_eventInfos[model.id])
        return 115;
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMThread *model;
    
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected)
    {
        model = _scheduledMailsDictionary[_sectionTitles[indexPath.section]][indexPath.row];
    }
    else
    {
        if(isFilter)
            model = [filteredMailArray objectAtIndex:indexPath.row];
        else
            model = [_itemMailArray objectAtIndex:indexPath.row];
    }
    
    if([_archivedMails containsObject:model])
    {
        PMArchivedMailUndoCell *cell = [PMArchivedMailUndoCell newCell];
        
        cell.archivedButtonTapAction = ^(id sender) {
            [self didArchiveMessage:model];
            [_archivedMails removeObject:model];
        };
        
        cell.undoButtonTapAction = ^(id sender) {
            
            NSString *folderId = model.folders[0][@"id"];
            
            [[PMAPIManager shared] moveThread:model toFolder:folderId completion:^(id data, id error, BOOL success)
            {
                if (!success) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You can't undo" message:[NSString stringWithFormat:@"%@",[error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                
                [self.tableView reloadData];
            }];
            
            [_archivedMails removeObject:model];
        };
        
        return cell;
    }
    else
    {
        // Load more mails
        NSInteger itemIndex = indexPath.item;
        
        if(!isFilter && itemIndex == _itemMailArray.count-1){
            if(loadMoreFlags==nil) loadMoreFlags = [[NSMutableDictionary alloc] init];
            
            BOOL loadMoreFlag = [loadMoreFlags objectForKey:@(itemIndex)];
            if(!loadMoreFlag)
            {
                [self updateMailsNextPage:YES];
                [loadMoreFlags setObject:[NSNumber numberWithBool:YES] forKey:@(itemIndex)];
            }
        }
        
        PMMailTVCell *cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:@"mailCell"];
        
        cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Notify me" backgroundColor:[UIColor colorWithRed:0.39 green:0.76 blue:0.7 alpha:1] callback:^BOOL(MGSwipeTableCell *sender) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateShowAlert:inboxMailModel:showAutoAsk:)]) {
                
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                _inboxMailModel = [_itemMailArray objectAtIndex:indexPath.row];
                
                [_delegate PMMessagesTableViewDelegateShowAlert:self inboxMailModel:_inboxMailModel showAutoAsk:YES];
            }
            
            
            return YES;
        }],[MGSwipeButton buttonWithTitle:@"Snooze" backgroundColor:[UIColor orangeColor] callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            _inboxMailModel = [_itemMailArray objectAtIndex:indexPath.row];
            
            if ([self isSentLabel]) {
                return YES;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateShowAlert:inboxMailModel:showAutoAsk:)]) {
                
                [_delegate PMMessagesTableViewDelegateShowAlert:self inboxMailModel:_inboxMailModel showAutoAsk:NO];
            }
            
            return YES;
        }]];
        
        
        UIColor *color = [UIColor colorWithRed:0.0f green:128.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Archive" backgroundColor:color callback:^BOOL(MGSwipeTableCell *sender) {
            
            [self showAlertWithCellIndexPath:[self.tableView indexPathForCell:cell]];
            
            return NO;
        }]];
        
        cell.rightExpansion.buttonIndex = 0;
        cell.leftExpansion.buttonIndex = 0;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.leftExpansion.fillOnTrigger = YES;
        cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
        cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
        
        
        
        __weak PMMessagesTableView *weakSelf = self;
        cell.btnRSVPTapAction = ^(id sender) {
            if([weakSelf.delegate respondsToSelector:@selector(didTapRSVPButton:model:)])
                [weakSelf.delegate didTapRSVPButton:sender model:model];
            
        };
        
        //NSString *keyphrases = [keyphrasesArray objectForKey:model.Id];
        
        BOOL isComeFromSalesforce = NO;
        if(_salesforces[model.id]) isComeFromSalesforce = [_salesforces[model.id] boolValue];
        [(PMMailTVCell *)cell updateWithModel:model keyphrases:nil eventInfo:_eventInfos[model.id] salesforce:isComeFromSalesforce];
        
        
        //Setting Long Press Gesture Recognizer
        //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        //[cell addGestureRecognizer:longPressGesture];
        
        
        if ([self getSelectedTableType] == ReadLaterMessagesSelected) {
            [cell showBtnUnsubscribe];
            cell.btnUnsubscribeAction = ^(id sender) {
                if([weakSelf.delegate respondsToSelector:@selector(didTapUnsubscribeButton:model:)])
                    [weakSelf.delegate didTapUnsubscribeButton:sender model:model];
            };
        }
        ((PMMailTVCell*)cell).cellDelegate = self;
        
        return cell;
    }
    
}
-(void)btnShowOriginalPressed:(id)sender
{
    PMMailTVCell *cell = (PMMailTVCell*)sender;
    
    PMThread *model = cell.model;
    BOOL isComeFromSalesforce = NO;
    if(_salesforces[model.id]) isComeFromSalesforce = [_salesforces[model.id] boolValue];
    
    [cell updateWithModel:model keyphrases:nil eventInfo:_eventInfos[model.id] salesforce:isComeFromSalesforce];
    [keyphrasesArray removeObjectForKey:cell.model.id];
    [_tableView beginUpdates];
    [_tableView endUpdates];
}
- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        
        PMMailTVCell *cell = (PMMailTVCell *)[gesture view];
        
        [cell showLoadingProgressBar];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        PMThread *lItem = [_itemMailArray objectAtIndex:indexPath.row];
        
        NSString *keyphrases = [keyphrasesArray objectForKey:lItem.id];
        
        if(keyphrases != nil)
        {
            BOOL isComeFromSalesforce = NO;
            if(_salesforces[lItem.id]) isComeFromSalesforce = [_salesforces[lItem.id] boolValue];
            
            [cell updateWithModel:lItem keyphrases:keyphrases eventInfo:_eventInfos[lItem.id] salesforce:isComeFromSalesforce];
            [cell hideLoadingProgressBar];
            
        }
        else
        {
            [[PMAPIManager shared] getMessagesWithThreadId:lItem.id forAccount:_inboxMailModel.accountId completion:^(id data, id error, BOOL success)
            {
                if (success)
                {
                    
                    NSMutableString *allPlainText = [[NSMutableString alloc] init];
                    NSMutableString *allSubject = [[NSMutableString alloc] init];
                    for(NSDictionary *item in data)
                    {
                        NSString *plainText = [[PMTextManager shared] convertHTML:item[@"body"]];
                        [allPlainText appendString:[NSString stringWithFormat:@"%@\n\n", plainText]];
                        [allSubject appendString:[NSString stringWithFormat:@"%@\n\n", item[@"subject"]]];
                    }
                    
                    
                    [[PMAPIManager shared] getKeywordPhrasesFromText:allPlainText subject:allSubject completion:^(id data, id error, BOOL success) {
                        if(success)
                        {
                            NSMutableString *keyphrasesString = [NSMutableString new];
                            
                            int cnt = 0;
                            for(NSString *keyword in data)
                            {
                                if(cnt>6) break;
                                
                                [keyphrasesString appendFormat:@"%@, ", keyword];
                                cnt ++;
                            }
                            
                            NSString *finalKeyphrasesString = [keyphrasesString substringToIndex:(keyphrasesString.length-2)];
                            [keyphrasesArray setObject:finalKeyphrasesString forKey:lItem.id];
                            
                            BOOL isComeFromSalesforce = NO;
                            if(_salesforces[lItem.id]) isComeFromSalesforce = [_salesforces[lItem.id] boolValue];
                            
                            [cell updateWithModel:lItem keyphrases:keyphrasesString eventInfo:_eventInfos[lItem.id] salesforce:isComeFromSalesforce];
                        }
                        
                        [cell hideLoadingProgressBar];
                        [_tableView beginUpdates];
                        [_tableView endUpdates];
                    }];
                }
                else
                {
                    [cell hideLoadingProgressBar];
                    [_tableView beginUpdates];
                    [_tableView endUpdates];
                }
            }];
        }
        
        [_tableView beginUpdates];
        [_tableView endUpdates];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected) {
        
        return [_scheduledMailsDictionary[_sectionTitles[section]] count];
    }
    
    if(isFilter)
    {
        return filteredMailArray.count;
    }
    
    return _itemMailArray.count > 0 ? _itemMailArray.count : 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected) {
        return [_sectionTitles count];
    }
    return 1;
}


- (void)buildScheduledDataWithMails:(NSArray*)mails
{
    _scheduledMailsDictionary = [NSMutableDictionary new];
    _sectionTitles = [NSMutableArray new];
    
    for(PMThread *mail in mails)
    {
        NSString *dateTypeString = [[PMScheduleManager sharedInstance] getStringTypeFromEnum:mail.snoozeDateType];
        
        if(![_sectionTitles containsObject:dateTypeString])
        {
            [_sectionTitles addObject:dateTypeString];
        }
        
        NSMutableArray *mailsWithDateType = [_scheduledMailsDictionary objectForKey:dateTypeString];
        
        if(mailsWithDateType==nil) mailsWithDateType = [NSMutableArray new];
        
        [mailsWithDateType addObject:mail];
        
        [_scheduledMailsDictionary setObject:mailsWithDateType forKey:dateTypeString];
        
    }
    
    [_sectionTitles sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSInteger index1 = [SCHEDULED_SECTIONS indexOfObject:obj1];
        NSInteger index2 = [SCHEDULED_SECTIONS indexOfObject:obj2];
        
        if (index1 < index2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
    
    for(NSString *section in _sectionTitles)
    {
        NSMutableArray *mails = _scheduledMailsDictionary[section];
        
        [mails sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PMThread *mail1 = (PMThread*)obj1;
            PMThread *mail2 = (PMThread*)obj2;
            
            
            return [mail1.snoozeDate compare:mail2.snoozeDate];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMThread *lSelectedMessageModel;

    
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected)
    {
        lSelectedMessageModel = _scheduledMailsDictionary[_sectionTitles[indexPath.section]][indexPath.row];
        [self selectedMessage:lSelectedMessageModel];
        return;
    }
    
    if(isFilter)
        lSelectedMessageModel = filteredMailArray[indexPath.row];
    else
        lSelectedMessageModel = _itemMailArray[indexPath.row];
    
    [self selectedMessage:lSelectedMessageModel];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected) {
        
         return _sectionTitles[section];
    }
    return nil;
}

#pragma mark - Public methods

- (void)initializeMessageTableView
{
    if(loadMoreFlags) [loadMoreFlags removeAllObjects];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    
    [self.tableView reloadData];
}
- (void)reloadMessagesTableView {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateGetData:)]) {
        NSArray *lItemArray = [_delegate PMMessagesTableViewDelegateGetData:self];
        if (lItemArray != nil) {
            _itemMailArray = [NSMutableArray arrayWithArray:lItemArray];
        } else {
            _itemMailArray = [NSMutableArray array];
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
            [self updateMailAdditionalInfo];
        });
        //[self performSelectorInBackground:@selector(updateMailAdditionalInfo) withObject:nil];
        
        [self getSelectedTableType];
        if(_selectedTableType == FollowUpsMessagesSelected)
        {
            [self buildScheduledDataWithMails:_itemMailArray];
        }
        [_tableView reloadData];
    }
}

-(void)updateMailAdditionalInfo
{
    if(_eventInfos == nil) _eventInfos = [NSMutableDictionary new];
    if(_salesforces == nil) _salesforces = [NSMutableDictionary new];
    
    __block NSInteger totalCnt = _itemMailArray.count;
    __block NSInteger cnt = 0;
    
    NSManagedObjectContext *context = [[DBManager instance] workerContext];
    
    for(PMThread *model in _itemMailArray)
    {
        [model getAdditionalInfo:context completion:^(NSDictionary *info) {
            if(info[@"start_time"])
            {
                [_eventInfos setObject:info forKey:model.id];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED object:model];
            }
            if(info[@"salesforce"])
            {
                [_salesforces setObject:@(YES) forKey:model.id];
            }
            cnt++;
            
            if(cnt == totalCnt)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
        }];
    }    
}
-(void)updateAdditionalInfoForMail:(PMThread*)mail
{
//    [mail getEventInfo:^(NSDictionary *info) {
//        if(info)
//        {
//            [_eventInfos setObject:info forKey:mail.Id];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED object:mail];
//        }
//    }];
    
    if([mail isComeFromSalesforce])
    {
        [_salesforces setObject:@(YES) forKey:mail.id];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED object:mail];
    }
    
}
#pragma mark - Private methods

- (void)updateMails {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateupdateData:)]) {
        [_delegate PMMessagesTableViewDelegateupdateData:self];
    }
}

- (void)updateMailsNextPage:(BOOL)nextPage
{
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateupdateData:nextPage:)]) {
        [_delegate PMMessagesTableViewDelegateupdateData:self nextPage:YES];
    }
}
- (void)selectedMessage:(PMThread *)msgModel {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegate:selectedMessage:selectedMessageArray:)])
    {
        NSMutableArray *messageArray = [NSMutableArray new];
        
        if (_selectedTableType == FollowUpsMessagesSelected) {
            for(NSInteger section=0; section<_sectionTitles.count; section++)
            {
                NSArray *mails = _scheduledMailsDictionary[_sectionTitles[section]];
                [messageArray addObjectsFromArray:mails];
            }
        }
        else
        {
            if(isFilter) [messageArray addObjectsFromArray:filteredMailArray];
            else [messageArray addObjectsFromArray:_itemMailArray];
        }
        [_delegate PMMessagesTableViewDelegate:self selectedMessage:msgModel selectedMessageArray:messageArray];
    }
}

#pragma mark - Alert Stuff

- (void)archiveMessage:(NSIndexPath*)indexPath
{
    _inboxMailModel = _itemMailArray[indexPath.row];
    
        
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Archiving message..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
    [[PMAPIManager shared] archiveThread:_inboxMailModel completion:^(id data, id error, BOOL success) {
        [AlertManager hideStatusBar:issuedTime];
        if (success) {
            if(!_archivedMails) _archivedMails = [NSMutableArray new];
            
            [_archivedMails addObject:_inboxMailModel];
            [self.tableView reloadData];
            
            [self performSelector:@selector(checkArchivedStatus:) withObject:_inboxMailModel afterDelay:3];
        } else {
            [AlertManager showStatusBarWithMessage:@"Archiving message failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
            [self.tableView reloadData];
            
        }
        
    }];
}
-(void)didArchiveMessage:(PMThread*)mail
{
//    [_itemMailArray removeObject:mail];
//    
//    //delete from local database
//    [DBInboxMailModel deleteWithThreadId:mail.Id];
//    
//    [_archivedMails removeObject:mail];
//    [self.tableView reloadData];
    
    [AlertManager showStatusBarWithMessage:@"Message archived." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
    
    if([_delegate respondsToSelector:@selector(didThreadArchived:)])
        [_delegate didThreadArchived:mail];
}
-(void)checkArchivedStatus:(id)sender
{
    PMThread *mail = sender;
    
    if([_archivedMails containsObject:mail])
    {
        [self didArchiveMessage:mail];
    }
}
-(void)showAlertWithCellIndexPath:(NSIndexPath*)indexPath {
    
    [self archiveMessage:indexPath];
    
}

#pragma mark - Enum stuff

-(selectedMessages)getSelectedTableType {
    
    if (_delegate && [_delegate respondsToSelector:@selector(getMessagesType)]) {
        _selectedTableType = [_delegate getMessagesType];
    }
    return _selectedTableType;
}



- (void)filterMessagesWithType:(NSString *)type
{
    
    isFilter = YES;
    filterName = type;
    
    [self filterMailsWithType:type];
    
    [self getSelectedTableType];
    if(_selectedTableType == FollowUpsMessagesSelected)
    {
        [self buildScheduledDataWithMails:filteredMailArray];
    }
    
    [_tableView reloadData];
}

-(void)filterMailsWithType:(NSString*)type
{
    NSPredicate *predicate;
    if([type isEqualToString:@"unread"])
        predicate = [NSPredicate predicateWithFormat:@"isUnread == 1"];
    else if([type isEqualToString:@"flagged"])
        predicate = [NSPredicate predicateWithFormat:@"isFlagged == 1"];
    else if([type isEqualToString:@"attachments"])
        predicate = [NSPredicate predicateWithFormat:@"hasAttachments == 1"];
    
    
    filteredMailArray  = [NSMutableArray arrayWithArray:[_itemMailArray filteredArrayUsingPredicate:predicate]];
}

- (void)clearFilter
{
    isFilter = NO;
    filterName = @"";
    
    
    [self getSelectedTableType];
    if(_selectedTableType == FollowUpsMessagesSelected)
    {
        [self buildScheduledDataWithMails:_itemMailArray];
    }
    
    [_tableView reloadData];
}

-(BOOL)isSentLabel {
    
    __block BOOL isSent = NO;

    [_inboxMailModel.folders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = notNullEmptyString(obj[@"name"]);
        
        if ([name isEqualToString:@"sent"]) {
            isSent = YES;
        }
    }];
    
    return isSent;
}

-(void)handlerNotificationMessageUpdated:(NSNotification*)notification
{
    PMThread *model = notification.object;
    [self performSelectorInBackground:@selector(updateAdditionalInfoForMail:) withObject:model];
}

-(void)handlerNotificationMailAdditionalInfoUpdated:(NSNotification*)notification
{
    if(isFilter) return;
    PMThread *model = (PMThread*)notification.object;
    
    NSIndexPath *indexPath;
    [self getSelectedTableType];
    if (_selectedTableType == FollowUpsMessagesSelected) {
        
        for(NSInteger section=0; section<_sectionTitles.count; section++)
        {
            BOOL bFind = NO;
            NSArray *mails = _scheduledMailsDictionary[_sectionTitles[section]];
            for(NSInteger row=0; row<mails.count; row++)
            {
                PMThread *m = mails[row];
                if([m.id isEqualToString:model.id])
                {
                    indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    bFind = YES;
                    break;
                }
            }
            if(bFind) break;
        }
    }
    else
    {
        for(NSInteger index=0; index<_itemMailArray.count; index++)
        {
            PMThread *m = _itemMailArray[index];
            if([m.id isEqualToString:model.id])
            {
                indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                break;
            }
        }
    }
    
    if(indexPath)
    {
        dispatch_async(dispatch_get_main_queue(), ^{            
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

-(void)removeInboxMailModel:(PMThread *)model
{
    NSInteger index = isFilter ? [filteredMailArray indexOfObject:model] : [_itemMailArray indexOfObject:model];
 
    [filteredMailArray removeObject:model];
    [_itemMailArray removeObject:model];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    
}
@end
