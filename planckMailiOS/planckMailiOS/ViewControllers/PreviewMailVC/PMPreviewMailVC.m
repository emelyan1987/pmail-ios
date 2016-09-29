//
//  PMPreviewMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailVC.h"

#import "PMPreviewMailTVCell.h"
#import "PMMailComposeVC.h"
#import "PMMessage.h"
#import "PMAPIManager.h"
#import "PMPreviewTableView.h"
#import "PMFilePreviewViewController.h"
#import "PMGystVC.h"
#import "AlertManager.h"
#import "PMSnoozeAlertViewController.h"
#import "DBSavedContact.h"
#import "PMCreateContactVC.h"
#import "PMPreviewPeopleVC.h"
#import "PMPeopleVC.h"
#import "PMSettingsManager.h"
#import "PMSFCreateContactNC.h"
#import "PMSFCreateLeadNC.h"
#import "PMRSVPManager.h"
#import "Config.h"
#import "PMFolderSelectVC.h"
#import "PMFolderManager.h"

@interface PMPreviewMailVC () <UIAlertViewDelegate, UIScrollViewDelegate, PMPreviewTableViewDelegate, PMAlertViewControllerDelegate, PMFolderSelectVCDelegate> {
    __weak IBOutlet UIScrollView *emailsScrollView;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
    
    NSMutableDictionary *addedEmailTables;
    NSInteger prevMailIndex;
    NSInteger currentTableIndex;
}

- (IBAction)replyBtnPressed:(id)sender;
- (IBAction)replyAllBtnPressed:(id)sender;
- (IBAction)forwardBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)btnDeletePressed:(id)sender;
- (IBAction)btnArchivePressed:(id)sender;
- (IBAction)btnMorePressed:(id)sender;

@property (nonatomic, strong) PMPreviewMailTVCell *prototypeCell;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@end

@implementation PMPreviewMailVC

#pragma mark - PMPreviewMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentSelectedArray = [NSMutableArray new];
    
    
    
    //_snoozeButton.hidden = _selectedTableType != FollowUpsMessagesSelected;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    //scrollView content size
    CGSize scrollSize = emailsScrollView.contentSize;
    NSInteger widthMultiplier = ([_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count]);
    if((_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) && widthMultiplier > 2) {
        widthMultiplier = 2;
    }
    scrollSize.width = SCREEN_WIDTH * widthMultiplier;
    emailsScrollView.contentSize = scrollSize;
    
    currentTableIndex = _selectedMailIndex == 0 ? 0 : 1;
    
    //scrollView content offset
    CGPoint scrollOffset = emailsScrollView.contentOffset;
    CGFloat scrollOffsetX = ([_inboxMailArray count] > 2 || _selectedMailIndex == 1) && (_selectedMailIndex != 0) ? SCREEN_WIDTH : 0.f;
    scrollOffset.x = scrollOffsetX;
    emailsScrollView.contentOffset = scrollOffset;
    
    prevMailIndex = _selectedMailIndex;
    [self performSelector:@selector(updatePreviewTables) withObject:nil afterDelay:0.01];
    
    [self configureBlurEffect];
}

#pragma mark - Configure Blur
-(void)configureBlurEffect {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    self.blurEffectView.frame = self.view.bounds;
}

#pragma mark - IBAction selectors

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDeletePressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure to delete this message?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] deleteThread:_inboxMailModel completion:^(id data, id error, BOOL success)
        {
            [AlertManager hideProgressBar];
            if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
            {
                [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionDelete mail:_inboxMailModel];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alert addAction:actionYes];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:actionNo];
    
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnArchivePressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure to archive this message?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] archiveThread:_inboxMailModel completion:^(id data, id error, BOOL success)
        {
            [AlertManager hideProgressBar];
            if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
            {
                [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionArchive mail:_inboxMailModel];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
            if(_inboxMailModel.isUnread)
            {
                PMFolderManager *folderManager = [PMFolderManager sharedInstance];
                NSString *archiveFolderId = [folderManager getFolderIdForAccount:_inboxMailModel.accountId folderName:@"Archive"];
                [folderManager increaseUnreadsForFolder:archiveFolderId];
                
                for(NSDictionary *folder in _inboxMailModel.folders)
                {
                    [folderManager decreaseUnreadsForFolder:folder[@"id"]];
                }
            }
        }];
    }];
    [alert addAction:actionYes];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:actionNo];
    
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnMorePressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    CGRect actionViewFrame = _actionView.frame;
    CGRect btnFrame = btn.frame;
    btnFrame.origin.x += actionViewFrame.origin.x;
    btnFrame.origin.y += actionViewFrame.origin.y;
    
    //rect.origin.y += rect.size.height;
    [self showActionMenu:sender];
}

-(void)showActionMenu:(id)sender
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionUnread = [UIAlertAction actionWithTitle:@"Mark Unread" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       [self menuSelected:@"Mark Unread"];
                                   }];
    UIAlertAction *actionImportant = [UIAlertAction actionWithTitle:@"Mark Important" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self menuSelected:@"Mark Important"];

                                    }];
    UIAlertAction *actionUnimportant = [UIAlertAction actionWithTitle:@"Mark Unimportant" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                            [self menuSelected:@"Mark Unimportant"];

                                        }];
    UIAlertAction *actionUnsubscribe = [UIAlertAction actionWithTitle:@"Unsubscribe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                            [self menuSelected:@"Unsubscribe"];

                                        }];
    UIAlertAction *actionMove = [UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                            [self menuSelected:@"Move"];

                                        }];
    UIAlertAction *actionSnooze = [UIAlertAction actionWithTitle:@"Snooze" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                            [self menuSelected:@"Snooze"];
                                        }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
    [alert addAction:actionUnread];
    [alert addAction:actionImportant];
    [alert addAction:actionUnimportant];
    [alert addAction:actionUnsubscribe];
    [alert addAction:actionMove];
    [alert addAction:actionSnooze];
    [alert addAction:actionCancel];
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)menuSelected:(NSString*)title
{
    if([title isEqualToString:@"Snooze"])
    {
        [self showSnoozeAlertForEmail:_inboxMailModel];
    }
    else if([title isEqualToString:@"Mark Unread"])
    {
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] markUnreadThread:_inboxMailModel completion:^(id error, BOOL success)
        {
            [AlertManager hideProgressBar];
            _inboxMailModel.isUnread = YES;
            
            if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
            {
                [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionMarkUnread mail:_inboxMailModel];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else if([title isEqualToString:@"Mark Important"])
    {
        if([_inboxMailModel belongsToFolder:@"Inbox"]) return;
        
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] markImportantThread:_inboxMailModel completion:^(id error, BOOL success)
         {
             [AlertManager hideProgressBar];
             if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
             {
                 [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionMarkImportant mail:_inboxMailModel];
             }
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else if([title isEqualToString:@"Mark Unimportant"])
    {
        if([_inboxMailModel belongsToFolder:@"Read Later"]) return;
        
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] markUnimportantThread:_inboxMailModel completion:^(id error, BOOL success)
         {
             [AlertManager hideProgressBar];
             if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
             {
                 [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionMarkUnimportant mail:_inboxMailModel];
             }
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else if([title isEqualToString:@"Unsubscribe"])
    {
        if([_inboxMailModel belongsToFolder:@"Black Hole"]) return;
        
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] unsubscribeThread:_inboxMailModel completion:^(id data, id error, BOOL success)
        {
            [AlertManager hideProgressBar];
            
            if(success)
            {
                [self unsubscribe:_inboxMailModel];
            }
        }];
        
    }
    else if([title isEqualToString:@"Move"])
    {
        PMFolderSelectVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMFolderSelectVC"];
        vc.delegate = self;
        vc.accountId = _inboxMailModel.accountId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)replyBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    NSDictionary *lItem = [messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    // get To email
    NSArray *to;
    NSString *myEmail = [[PMAPIManager shared].namespaceId.email_address lowercaseString];
    for(NSInteger i=messages.count-1; i>=0; i--)
    {
        NSDictionary *item = messages[i];
        
        NSString *email = [item[@"from"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            to = item[@"from"]; break;
        }
        
        email = [item[@"to"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            to = item[@"to"]; break;
        }
    }
    lDraft.to = to;
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    NSLog(@"Reply Messages: %@", messages);
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)replyAllBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    
    NSDictionary *lItem = [messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    //NSMutableArray *lEmailsArray = [NSMutableArray arrayWithArray:lItem[@"from"]];
    //[lEmailsArray addObjectsFromArray:lItem[@"to"]];
    //lDraft.to = lEmailsArray;
    // get To email
    NSMutableArray *to = [NSMutableArray new];
    NSString *myEmail = [[PMAPIManager shared].namespaceId.email_address lowercaseString];
    for(NSInteger i=messages.count-1; i>=0; i--)
    {
        NSDictionary *item = messages[i];
        
        NSString *email = [item[@"from"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            [to addObjectsFromArray:item[@"from"]];
        }
        
        email = [item[@"to"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            [to addObjectsFromArray:item[@"to"]];
        }
    }
    lDraft.to = to;
    
    
    lDraft.cc = lItem[@"cc"];
    lDraft.bcc = lItem[@"bcc"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)forwardBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    
    NSDictionary *lItem = [messages lastObject];
    
    lNewMailComposeVC.messageId = lItem[@"id"];//@"";
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    if ([_inboxMailModel.subject hasPrefix:@"Fwd:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Fwd: %@", _inboxMailModel.subject];
    }
    
    
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}


- (void)replyWithMessageData:(NSDictionary*)data
{
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    NSDictionary *lItem = [messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    // get To email
    NSArray *to;
    NSString *myEmail = [[PMAPIManager shared].namespaceId.email_address lowercaseString];
    for(NSInteger i=messages.count-1; i>=0; i--)
    {
        NSDictionary *item = messages[i];
        
        NSString *email = [item[@"from"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            to = item[@"from"]; break;
        }
        
        email = [item[@"to"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            to = item[@"to"]; break;
        }
    }
    lDraft.to = to;
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    NSLog(@"Reply Messages: %@", messages);
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)replyAllWithMessageData:(NSDictionary*)data
{
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    
    NSDictionary *lItem = [messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    //NSMutableArray *lEmailsArray = [NSMutableArray arrayWithArray:lItem[@"from"]];
    //[lEmailsArray addObjectsFromArray:lItem[@"to"]];
    //lDraft.to = lEmailsArray;
    // get To email
    NSMutableArray *to = [NSMutableArray new];
    NSString *myEmail = [[PMAPIManager shared].namespaceId.email_address lowercaseString];
    for(NSInteger i=messages.count-1; i>=0; i--)
    {
        NSDictionary *item = messages[i];
        
        NSString *email = [item[@"from"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            [to addObjectsFromArray:item[@"from"]];
        }
        
        email = [item[@"to"][0][@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            [to addObjectsFromArray:item[@"to"]];
        }
    }
    lDraft.to = to;
    
    
    lDraft.cc = lItem[@"cc"];
    lDraft.bcc = lItem[@"bcc"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)forwardWithMessageData:(NSDictionary*)data
{
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    PMPreviewTableView *currentPreviewTable = [addedEmailTables objectForKey:@(_selectedMailIndex)];
    NSArray *messages = currentPreviewTable.messages;
    
    NSDictionary *lItem = [messages lastObject];
    
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    if ([_inboxMailModel.subject hasPrefix:@"Fwd:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Fwd: %@", _inboxMailModel.subject];
    }
    
    
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    if(self.isRoot)
        [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
    else
        [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger selectedIndex = 1;
    BOOL shouldUpdate = NO;
    
    if(scrollView.contentOffset.x < scrollView.frame.size.width) {
        selectedIndex = 0;
    } else if (scrollView.contentOffset.x >= scrollView.frame.size.width &&
               scrollView.contentOffset.x < scrollView.frame.size.width * 2) {
        selectedIndex = 1;
    } else if (scrollView.contentOffset.x >= scrollView.frame.size.width * 2) {
        selectedIndex = 2;
    }
    
    NSInteger indexOffset = 0;
    if(selectedIndex != currentTableIndex) {
        shouldUpdate = YES;
        indexOffset = selectedIndex - currentTableIndex;
    }
    
    if(shouldUpdate) {
        prevMailIndex = _selectedMailIndex;
        _selectedMailIndex += indexOffset;
        
        self.messages = nil;
        self.inboxMailModel = _inboxMailArray[_selectedMailIndex];
        
        currentTableIndex = _selectedMailIndex == 0 ? 0 : 1;
        
        [self updatePreviewTables];
    }
}



#pragma mark - PMPreviewTableViewDelegate

- (void)PMPreviewTableView:(PMPreviewTableView *)previewTable didUpdateMessages:(NSArray *)messages {
    if([_inboxMailModel isEqual:previewTable.inboxMailModel]) {
        self.messages = [messages copy];
    }
}

-(void)PMPreviewTableViewDelegateShowAlert:(PMThread *)messagesTableView inboxMailModel:(PMThread *)mailModel {
    [self showSnoozeAlertForEmail:mailModel];
}

- (void)didTapUnsubscribeButton:(id)sender model:(PMThread *)model
{
    [AlertManager showProgressBarWithTitle:nil view:self.view];
    [[PMAPIManager shared] unsubscribeThread:model completion:^(id data, id error, BOOL success)
     {
         [AlertManager hideProgressBar];
         
         if(success)
         {
             [self unsubscribe:model];
         }
     }];
}

- (void)unsubscribe:(PMThread*)model
{
    NSArray *emails = [model getParticipantEmailsExcludingMe];
    
    if(emails && emails.count)
    {
        NSString *title = [NSString stringWithFormat:@"Unsubscribe from %@", [emails componentsJoinedByString:@","]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Planck mail will attempt to unsubscribe and delete email from selected senders. This action is not reversible." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Unsubscribe" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [AlertManager showProgressBarWithTitle:@"Unsubscribing..." view:self.view];
            [[PMAPIManager shared] addEmailToBlackList:emails forAccount:model.accountId completion:^(id data, id error, BOOL success) {
                [AlertManager hideProgressBar];
                if(success)
                {
                    DLog(@"Add Email To Black List Succedded");
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
                    {
                        [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionUnsubscribe mail:_inboxMailModel];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
        
        [alert addAction:cancel];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didTapBtnFlag:(UIButton *)sender thread:(PMThread *)thread
{
    BOOL flagged = thread.isFlagged;
    [AlertManager showProgressBarWithTitle:nil view:self.view];
    
    [[PMAPIManager shared] updateThread:thread.id forAccount:thread.accountId params:@{@"starred": [NSNumber numberWithBool:!flagged]} completion:^(id data, id error, BOOL success) {
        [AlertManager hideProgressBar];
        
        if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
        {
            [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionStarred mail:_inboxMailModel];
        }
    }];
}

#pragma mark - Private methods

- (void)showSnoozeAlertForEmail:(PMThread *)mailModel {
    PMSnoozeAlertViewController *alert = [[PMSnoozeAlertViewController alloc] init];
    alert.view.backgroundColor = [UIColor clearColor];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.inboxMailModel = mailModel;
    alert.delegate = self;
    [self presentViewController:alert animated:YES completion:nil];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view addSubview:self.blurEffectView];
        
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.tabBarController.tabBar.hidden = YES;
    }];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)updatePreviewTables {
    if(prevMailIndex != _selectedMailIndex) {
        //find index of table to delete
        NSInteger indexToDelete = 0;
        NSInteger indexToUpdate = -1;
        if(prevMailIndex < _selectedMailIndex) {
            indexToDelete = prevMailIndex - 1;
            if(_selectedMailIndex < [_inboxMailArray count] - 1) {
                indexToUpdate = 2;
            }
        } else {
            indexToDelete = prevMailIndex + 1;
            if(_selectedMailIndex > 0) {
                indexToUpdate = 0;
            }
        }
        PMPreviewTableView *previewTableToDelete = addedEmailTables[@(indexToDelete)];
        
        if(previewTableToDelete) {
            [previewTableToDelete removeFromSuperview];
            [addedEmailTables removeObjectForKey:@(indexToDelete)];
            previewTableToDelete = nil;
        }
        
        [self shiftTables];
        
        if(indexToUpdate >= 0) {
            [self addPreviewTableForIndex:[NSNumber numberWithInteger:indexToUpdate]];
        }
    } else if (!addedEmailTables) {
        addedEmailTables = [NSMutableDictionary new];
        
        NSInteger indexesCount = [_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count];
        if(_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) {
            indexesCount--;
        }
        /*for(NSInteger i = 0; i < indexesCount; i++) {
            [self addPreviewTableForIndex:i];
        }*/
        
        [self addPreviewTableForIndex:[NSNumber numberWithInteger:1]];
        [self performSelector:@selector(addPreviewTableForIndex:) withObject:[NSNumber numberWithInteger:0] afterDelay:.1];
        if(indexesCount==3)[self performSelector:@selector(addPreviewTableForIndex:) withObject:[NSNumber numberWithInteger:2] afterDelay:.1];
    }
    
    // Mark read
    if(self.inboxMailModel.isUnread)
    {
        [[PMAPIManager shared] markReadThread:_inboxMailModel completion:^(id error, BOOL success) {
            _inboxMailModel.isUnread = NO;
            if([_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
                [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionMarkRead mail:_inboxMailModel];
        }];
    }
    self.inboxMailModel.isUnread = NO;
}

- (void)addPreviewTableForIndex:(NSNumber*)indexNumber {
    NSInteger index = [indexNumber integerValue];
    
    
    PMPreviewTableView *previewTable = [PMPreviewTableView newPreviewView];
    previewTable.delegate = self;
    
    NSInteger mailIndex = _selectedMailIndex + (index - 1);
    if((_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count]) &&
       mailIndex + 1 < [_inboxMailArray count]) {
        mailIndex++;
    }
    
    previewTable.inboxMailModel = _inboxMailArray[mailIndex];
    
    CGRect previewFrame = previewTable.frame;
    previewFrame.origin.x = SCREEN_WIDTH * index;
    previewFrame.size.width = emailsScrollView.frame.size.width;
    previewFrame.size.height = emailsScrollView.frame.size.height;
    previewTable.frame = previewFrame;    
    
    
    [emailsScrollView addSubview:previewTable];
    
    [addedEmailTables setObject:previewTable forKey:@(mailIndex)];
}


- (void)shiftTables {
    if([_inboxMailArray count] < 3) {
        return;
    }
    
    //change content offset and shift tables
    BOOL doOffset = NO;
    CGFloat offsetValue = 0;
    if(_selectedMailIndex > prevMailIndex && prevMailIndex != 0) {
        doOffset = YES;
        offsetValue = -SCREEN_WIDTH;
    } else if (_selectedMailIndex < prevMailIndex) {
        if(_selectedMailIndex > 0) {
            doOffset = YES;
            offsetValue = SCREEN_WIDTH;
        }
    }
    if (doOffset) {
        for(UIView *previreTable in [addedEmailTables allValues]) {
            CGRect viewFrame = previreTable.frame;
            viewFrame.origin.x += offsetValue;
            previreTable.frame = viewFrame;
        }
        
        CGPoint scrollOffset = emailsScrollView.contentOffset;
        scrollOffset.x = SCREEN_WIDTH;
        emailsScrollView.contentOffset = scrollOffset;
    }
    
    //change content size
    if(prevMailIndex == 0 || prevMailIndex == [_inboxMailArray count] - 1) {//moved from edge
        CGSize scrollSize = emailsScrollView.contentSize;
        scrollSize.width = SCREEN_WIDTH * ([_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count]);
        emailsScrollView.contentSize = scrollSize;
    } else if (_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) {
        CGSize scrollSize = emailsScrollView.contentSize;
        scrollSize.width = SCREEN_WIDTH * 2;
        emailsScrollView.contentSize = scrollSize;
    }
}


#pragma PMPreviewTableViewDelegate
-(void)didSelectAttachment:(NSDictionary *)file
{
    if([file[@"filename"] isEqual:[NSNull null]]) return;
    
    PMFilePreviewViewController *controller = [FILES_STORYBOARD instantiateViewControllerWithIdentifier:@"PMFilePreviewViewController"];
    
    controller.file = file;
    
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)onGystAction:(NSArray *)messages
{
    
    PMGystVC *gystVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGystVC"];
    
    gystVC.inboxMailModel = _inboxMailModel;
    gystVC.messages = messages;
    
    [self presentViewController:gystVC animated:YES completion:nil];
}
-(void)didTapOnEmail:(NSString *)email name:(NSString*)name sender:(id)sender
{
    if(!email) return;
    
    __block DBSavedContact *contact = [DBSavedContact getContactWithEmail:email];
    
    if(contact)
    {        
        PMPreviewPeopleVC *lPreviewPeople = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMPreviewPeopleVC"];
        lPreviewPeople.contact = contact;
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:lPreviewPeople animated:YES];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:email message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *actionCreate = [UIAlertAction actionWithTitle:@"Create New Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            PMCreateContactVC *controller = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
            
            NSDictionary *data = @{@"emails":[NSMutableArray arrayWithArray:@[email]], @"name":name};
            controller.data = data;
            
            [self presentViewController:controller animated:YES completion:nil];
        }];
        [alert addAction:actionCreate];
        
        UIAlertAction *actionUpdate = [UIAlertAction actionWithTitle:@"Add to Existing Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            PMPeopleVC *controller = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMPeopleVC"];
            controller.isPicker = YES;
            controller.email = email;
            
            
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController pushViewController:controller animated:YES];
        }];
        [alert addAction:actionUpdate];
        
        if([[PMSettingsManager instance] getEnabledSalesforce])
        {
            UIAlertAction *actionCreateSalesforceContact = [UIAlertAction actionWithTitle:@"Create New Salesforce Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                PMSFCreateContactNC *controller = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFCreateContactNC"];
                
                NSArray *names = [name componentsSeparatedByString:@" "];
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"Email":email}];
                if(names.count)
                {
                    [data setObject:names[0] forKey:@"FirstName"];
                    if(names.count>1) [data setObject:[names lastObject] forKey:@"LastName"];
                    if(names.count>2) [data setObject:names[1] forKey:@"MiddleName"];
                }
                controller.data = data;
                
                [self presentViewController:controller animated:YES completion:nil];
            }];
            [alert addAction:actionCreateSalesforceContact];
            
            UIAlertAction *actionCreateSalesforceLead = [UIAlertAction actionWithTitle:@"Create New Salesforce Lead" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                PMSFCreateLeadNC *controller = [LEADS_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFCreateLeadNC"];
                
                NSArray *names = [name componentsSeparatedByString:@" "];
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"Email":email}];
                if(names.count)
                {
                    [data setObject:names[0] forKey:@"FirstName"];
                    if(names.count>1) [data setObject:[names lastObject] forKey:@"LastName"];
                    if(names.count>2) [data setObject:names[1] forKey:@"MiddleName"];
                }
                controller.data = data;
                
                [self presentViewController:controller animated:YES completion:nil];
            }];
            [alert addAction:actionCreateSalesforceLead];
        }
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionCancel];
        
        alert.popoverPresentationController.sourceView = (UIView*)sender;
        alert.popoverPresentationController.sourceRect = ((UIView*)sender).bounds;
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}
-(void)didTapBtnRSVP:(UIButton *)sender eventId:(NSString *)eventId
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:eventId type:RSVP_TYPE_ACCEPT completion:nil];
    }];
    UIAlertAction *actionTentative = [UIAlertAction actionWithTitle:@"Tentative" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:eventId type:RSVP_TYPE_TENTATIVE completion:nil];
    }];
    UIAlertAction *actionDecline = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:eventId type:RSVP_TYPE_DECLINE completion:nil];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionAccept];
    [alert addAction:actionTentative];
    [alert addAction:actionDecline];
    [alert addAction:actionCancel];
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)didTapBtnReply:(UIButton *)sender messageData:(NSDictionary *)data
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionReply = [UIAlertAction actionWithTitle:@"Reply" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [self replyWithMessageData:data];
    }];
    UIAlertAction *actionReplyAll = [UIAlertAction actionWithTitle:@"Reply All" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [self replyAllWithMessageData:data];
    }];
    UIAlertAction *actionForward = [UIAlertAction actionWithTitle:@"Forward" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [self forwardWithMessageData:data];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionReply];
    [alert addAction:actionReplyAll];
    [alert addAction:actionForward];
    [alert addAction:actionCancel];
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - PMAlertViewControllerDelegate

- (void)didScheduleWithDateType:(ScheduleDateType)dateType date:(NSDate *)date autoAsk:(NSInteger)autoAsk
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        
        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
        
        if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
        {
            [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionSnooze mail:_inboxMailModel];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didCancelSchdule
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        
        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
    }];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark PMSelectFolderVCDelegate
- (void)didSelectFolder:(NSString *)folderId
{
    if([_inboxMailModel belongsToFolder:folderId]) return;
    
    [[PMAPIManager shared] moveThread:_inboxMailModel toFolder:folderId completion:^(id data, id error, BOOL success) {
        if(success)
        {
            if([_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)])
            {
                [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionMove mail:_inboxMailModel];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
