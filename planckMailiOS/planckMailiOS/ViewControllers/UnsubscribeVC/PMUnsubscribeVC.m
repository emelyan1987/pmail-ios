//
//  PMUnsubscribeVC.m
//  planckMailiOS
//
//  Created by LionStar on 3/5/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMUnsubscribeVC.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "UITableView+BackgroundText.h"
#import "PMUnsubscribeTVC.h"
#import "DBContact.h"
#import "DBManager.h"
#import "Config.h"
#import "KGModal.h"
#import "PMSwitchAccountVC.h"
#import "PMSettingsManager.h"

#import <MBProgressHUD.h>


@interface PMUnsubscribeVC () <UITableViewDataSource, UITableViewDelegate, PMSwitchAccountVCDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnActiveSpammer;
@property (weak, nonatomic) IBOutlet UIButton *btnBlocked;
@property (weak, nonatomic) IBOutlet UIView *viewSelectedTabLine;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectNone;
@property (weak, nonatomic) IBOutlet UIButton *btnUnsubscribe;
@property (weak, nonatomic) IBOutlet UIButton *btnKeep;
@property (weak, nonatomic) IBOutlet UILabel *lblTip;
@property (weak, nonatomic) IBOutlet UITableView *tblActiveSpammers;
@property (weak, nonatomic) IBOutlet UITableView *tblBlockedList;

@property UITableView *currentTable;

- (IBAction)btnActiveSpammerClicked:(id)sender;
- (IBAction)btnBlockedClicked:(id)sender;
- (IBAction)btnSelectAllClicked:(id)sender;
- (IBAction)btnSelectNoneClicked:(id)sender;
- (IBAction)btnUnsubscribeClicked:(id)sender;
- (IBAction)btnKeepClicked:(id)sender;
- (IBAction)btnSwitchAccountClicked:(id)sender;

@property (nonatomic, assign) SelectedTab selectedTab;
@property (nonatomic, strong) NSMutableArray *blacklist;
@property (nonatomic, strong) NSMutableArray *activeSpammers;
@property (nonatomic, strong) NSMutableDictionary *selectedItems;

@property (nonatomic, strong) DBNamespace *selectedNamespace;

@property (nonatomic, assign) BOOL isLoadingActiveSpammers;
@property (nonatomic, assign) BOOL isLoadingBlackList;
@end

@implementation PMUnsubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    _btnUnsubscribe.enabled = _btnKeep.enabled = NO;
    [_btnUnsubscribe setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
    [_btnKeep setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
    
    _selectedNamespace = [[PMAPIManager shared] namespaceId];
    
    [self setTitleView];
    
    [_tblActiveSpammers showEmptyMessage:@"There are no any spammers"]; [_tblActiveSpammers setHidden:YES];
    [_tblBlockedList showEmptyMessage:@"There are no blacked email list."]; [_tblBlockedList setHidden:YES];
    
    
    [self loadData];
    
    [self selectTab:TabSelectedActiveSpammer];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:NOTIFICATION_EMAIL_ADDED_TO_BLACK_LIST object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:NOTIFICATION_EMAIL_REMOVED_FROM_BLACK_LIST object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setTitleView
{
    NSString *title = @"Unsubscribe";
    
    CGFloat width;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = size.height;
    }
    else {
        width = size.width;
    }
    width -= 168;
    
    UILabel *lblTitle = [[UILabel alloc]init];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [lblTitle setFont:font];
    lblTitle.text = title;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 1;
    lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    lblTitle.frame = CGRectMake(0, 0, width, 25);
    
    UILabel *lblEmail = [[UILabel alloc]init];
    [lblEmail setFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    lblEmail.text = _selectedNamespace.email_address;
    lblEmail.textColor = [UIColor whiteColor];
    lblEmail.textAlignment = NSTextAlignmentCenter;
    lblEmail.numberOfLines = 1;
    lblEmail.lineBreakMode = NSLineBreakByTruncatingTail;
    lblEmail.frame = CGRectMake(0, 26, width, 15);
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    
    [headerview addSubview:lblTitle];
    [headerview addSubview:lblEmail];
    
    self.navigationItem.titleView = headerview;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnSwitchAccountClicked:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 53, 31)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 20, 50, 20)];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [label setText:@"Switch"];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    
}

- (void)loadData
{
    [self loadActiveSpammers];
    [self loadBlackList];
}
- (void)loadActiveSpammers
{
    
    NSString *email = _selectedNamespace.email_address;
    
    _isLoadingActiveSpammers = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_tblActiveSpammers animated:YES];
    hud.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
    hud.labelText = @"Loading Active Spammers...";
    
    [[PMAPIManager shared] getActiveSpammers:email count:50 completion:^(id data, id error, BOOL success) {
        [hud hide:YES];
        _isLoadingActiveSpammers = NO;
        
        _activeSpammers = [NSMutableArray new];
        _selectedItems = [NSMutableDictionary new];
        
        if(success)
        {
            NSDictionary *result = data;
            NSArray *emails = [result[@"emails"] componentsSeparatedByString: @";"];
            NSArray *names = [result[@"names"] componentsSeparatedByString: @";"];
            NSArray *counts = [result[@"counts"] componentsSeparatedByString: @";"];
            
            for(NSInteger index=0; index<emails.count; index++)
            {
                NSString *email = emails[index];
                if(![self isInBlackList:email])
                {
                    [_activeSpammers addObject:@{@"email":email,@"name":names[index],@"count":counts[index]}];
                }
            }
        }
        
        [_tblActiveSpammers.backgroundView setHidden:_activeSpammers.count];
        [_tblActiveSpammers reloadData];
        
    }];
}
- (void)loadBlackList
{
    _blacklist = [NSMutableArray new];
    
    NSString *email = _selectedNamespace.email_address;
    
    _isLoadingBlackList = YES;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_tblBlockedList animated:YES];
    hud.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
    hud.labelText = @"Loading Blocked List...";
    
    [[PMAPIManager shared] getBlackList:email completion:^(id data, id error, BOOL success) {
        _isLoadingBlackList = NO;
        [hud hide:YES];
        
        if(success)
        {
            [_blacklist addObjectsFromArray:data];
            
            [self removeBlockedEmailsFromSpammers];
        }
        
        [_tblBlockedList.backgroundView setHidden:_blacklist.count];
        [_tblBlockedList reloadData];
        
    }];
}

- (void)removeBlockedEmailsFromSpammers
{
    NSMutableArray *spammersToBlock = [NSMutableArray new];
    for(NSDictionary *spammerItem in _activeSpammers)
    {
        if([self isInBlackList:spammerItem[@"email"]])
            [spammersToBlock addObject:spammerItem];
    }
    
    for(NSDictionary *item in spammersToBlock)
    {
        [_activeSpammers removeObject:item];
    }
}

- (BOOL)isInBlackList:(NSString*)email {
    for(NSDictionary *item in _blacklist)
    {
        if([[email lowercaseString] isEqualToString:[item[@"email"] lowercaseString]]) return YES;
    }
    
    return NO;
}

//- (void)loadMailCount
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _btnActiveSpammer.enabled = NO;
//        _btnBlocked.enabled = NO;
//    });
//    
//    for(NSInteger index=0; index<_activeSpammers.count; index++)
//    {
//        NSMutableDictionary *item = _activeSpammers[index];
//        NSString *email = item[@"email"];
//        
//        if(!item[@"count"])
//        {            
//            [[PMAPIManager shared] getMailsCountFromEmail:email forAccount:_selectedNamespace.account_id completion:^(id data, id error, BOOL success) {
//                
//                
//                [item setObject:success?data:@(0) forKey:@"count"];
//                
//                [_activeSpammers replaceObjectAtIndex:index withObject:item];
//                
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_tableView beginUpdates];
//                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                    [_tableView endUpdates];
//                    
//                    if(index == _activeSpammers.count-1)
//                    {
//                        _btnActiveSpammer.enabled = YES;
//                        _btnBlocked.enabled = YES;
//                        
//                        [_activeSpammers sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                            NSInteger count1 = obj1[@"count"] ? [obj1[@"count"] integerValue] : 0;
//                            NSInteger count2 = obj2[@"count"] ? [obj2[@"count"] integerValue] : 0;
//                            
//                            if (count1 > count2) {
//                                return (NSComparisonResult)NSOrderedAscending;
//                            } else {
//                                return (NSComparisonResult)NSOrderedDescending;
//                            }
//                        }];
//                        
//                        [_tableView reloadData];
//                    }
//                });
//            }];
//        }
//    }
//}

- (BOOL)isInActiveSpammers:(NSDictionary*)item
{
    NSString *email = item[@"email"];
    
    for(NSDictionary *item1 in _activeSpammers)
    {
        if([item1[@"email"] isEqualToString:email])
            return YES;
    }
    
    return NO;
}
-(void)selectTab:(SelectedTab)selectedTab
{
    CGRect lineFrame;
    
    if (selectedTab == TabSelectedActiveSpammer)
    {
        self.lblTip.text = @"SELECT SENDERS AND UNSUBSCRIBE";
        
        [self.btnActiveSpammer setTitleColor:PM_TURQUOISE_COLOR forState:UIControlStateNormal];
        [self.btnBlocked setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
        
        lineFrame = CGRectMake(_btnActiveSpammer.frame.origin.x, _btnActiveSpammer.frame.origin.y+_btnActiveSpammer.frame.size.height - 4, _btnActiveSpammer.frame.size.width, 3);
        
        _tblActiveSpammers.hidden = NO; _tblBlockedList.hidden = YES;
        _currentTable = _tblActiveSpammers;
       
    }
    else if (selectedTab == TabSelectedBlocked)
    {
        self.lblTip.text = @"SELECT BLOCKED SENDER AND SUBSCRIBE";
        
        [self.btnBlocked setTitleColor:PM_TURQUOISE_COLOR forState:UIControlStateNormal];
        [self.btnActiveSpammer setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
        
        lineFrame = CGRectMake(_btnBlocked.frame.origin.x, _btnBlocked.frame.origin.y+_btnBlocked.frame.size.height - 4, _btnBlocked.frame.size.width, 3);
        
        _tblActiveSpammers.hidden = YES; _tblBlockedList.hidden = NO;
        _currentTable = _tblBlockedList;
    }
    
    [UIView animateWithDuration:.2f animations:^{
        [_viewSelectedTabLine setFrame:lineFrame];
    }];
    
    [self.btnActiveSpammer.titleLabel setFont:selectedTab==TabSelectedActiveSpammer?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.btnBlocked.titleLabel setFont:selectedTab==TabSelectedBlocked?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    
    _selectedTab = selectedTab;
    
}

- (IBAction)btnActiveSpammerClicked:(id)sender {
    [self selectTab:TabSelectedActiveSpammer];
    
    _btnUnsubscribe.hidden = NO; _btnKeep.hidden = YES;
}

- (IBAction)btnBlockedClicked:(id)sender {
    [self selectTab:TabSelectedBlocked];
    
    _btnUnsubscribe.hidden = YES; _btnKeep.hidden = NO;
}

- (IBAction)btnSelectAllClicked:(id)sender
{
    NSArray *items = _selectedTab == TabSelectedActiveSpammer ? _activeSpammers : _blacklist;
    if(items && items.count)
    {        
        for(NSDictionary *item in items)
        {
            NSString *email = item[@"email"];
            
            [_selectedItems setObject:@(YES) forKey:email];
        }
        
        [_currentTable reloadData];
        
        _btnSelectAll.hidden = YES;
        _btnSelectNone.hidden = NO;
        
        _btnUnsubscribe.enabled = _btnKeep.enabled = YES;
        [_btnUnsubscribe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnKeep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}


- (IBAction)btnSelectNoneClicked:(id)sender
{
    NSArray *items = _selectedTab == TabSelectedActiveSpammer ? _activeSpammers : _blacklist;
    for(NSDictionary *item in items)
    {
        NSString *email = item[@"email"];
        
        [_selectedItems setObject:@(NO) forKey:email];
    }
    
    [_currentTable reloadData];
    
    _btnSelectAll.hidden = NO;
    _btnSelectNone.hidden = YES;
    
    _btnUnsubscribe.enabled = _btnKeep.enabled = NO;
    [_btnUnsubscribe setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
    [_btnKeep setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
}

- (BOOL)selectedItemsExist
{
    for(NSString *email in [_selectedItems allKeys])
    {
        BOOL selected = [[_selectedItems objectForKey:email] boolValue];
        if(selected) return YES;
    }
    
    return NO;
}
- (IBAction)btnUnsubscribeClicked:(id)sender
{
    if(![self selectedItemsExist]) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unsubscribe" message:@"Planck mail will attempt to unsubscribe and delete email from selected senders. This action is not reversible." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Unsubscribe" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *selectedItems = [NSMutableArray new];
        NSMutableArray *selectedEmails = [NSMutableArray new];
        
        for(NSDictionary *item in _activeSpammers)
        {
            NSString *email = item[@"email"];
            BOOL selected = [_selectedItems objectForKey:email]?[[_selectedItems objectForKey:email] boolValue]:NO;
            
            if(selected)
            {
                [selectedEmails addObject:email];
                
                [selectedItems addObject:item];
            }
        }
        
        [AlertManager showProgressBarWithTitle:@"Unsubscribing..." view:self.view];
        [[PMAPIManager shared] addEmailToBlackList:selectedEmails forAccount:_selectedNamespace.account_id completion:^(id data, id error, BOOL success)
         {
             [AlertManager hideProgressBar];
//             if(success)
//             {
//                 DLog(@"Add Email To Black List Succedded");
//                 
//                 for(NSString *email in selectedEmails)
//                     [_selectedItems removeObjectForKey:email];
//                 
//                 NSMutableArray *indexPaths = [NSMutableArray new];
//                 for(NSDictionary *item in selectedItems)
//                 {
//                     NSInteger index = [_activeSpammers indexOfObject:item];
//                     [_activeSpammers removeObject:item];
//                     [_blacklist addObject:item];
//                     
//                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                     
//                     [indexPaths addObject:indexPath];
//                 }
//                 
//                 
//                 
//                 [_tableView beginUpdates];
//                 [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//                 [_tableView endUpdates];
//             }
         }];
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnKeepClicked:(id)sender
{
    if(![self selectedItemsExist]) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Subscribe" message:@"Planck mail will attempt to subscribe and the selected senders will be unblocked from now." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Keep" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *selectedItems = [NSMutableArray new];
        NSMutableArray *selectedEmails = [NSMutableArray new];
        
        for(NSDictionary *item in _blacklist)
        {
            NSString *email = item[@"email"];
            BOOL selected = [_selectedItems objectForKey:email]?[[_selectedItems objectForKey:email] boolValue]:NO;
            
            if(selected)
            {
                [selectedEmails addObject:email];
                [selectedItems addObject:item];
            }
        }
        
        [AlertManager showProgressBarWithTitle:@"Keeping..." view:self.view];
        [[PMAPIManager shared] removeEmailFromBlackList:selectedEmails forAccount:_selectedNamespace.account_id completion:^(id data, id error, BOOL success)
         {
             [AlertManager hideProgressBar];
//             if(success)
//             {
//                 for(NSString *email in selectedEmails)
//                     [_selectedItems removeObjectForKey:email];
//                 
//                 NSMutableArray *indexPaths = [NSMutableArray new];
//                 
//                 for(NSDictionary *item in selectedItems)
//                 {
//                     NSInteger index = [_blacklist indexOfObject:item];
//                     [_blacklist removeObject:item];
//                     [_activeSpammers addObject:item];
//                     
//                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                     
//                     [indexPaths addObject:indexPath];
//                 }
//                 
//                 [_tableView beginUpdates];
//                 [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
//                 [_tableView endUpdates];
//             }
         }];
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)btnSwitchAccountClicked:(id)sender {
    PMSwitchAccountVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSwitchAccountVC"];
    vc.selectedAccount = _selectedNamespace;
    vc.delegate = self;
    [[KGModal sharedInstance] showWithContentViewController:vc andAnimated:YES];
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:_tblActiveSpammers])
    {
        return _activeSpammers.count;
    }
    else if([tableView isEqual:_tblBlockedList])
    {
        return _blacklist.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMUnsubscribeTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"UnsubscribeCell"];
    
    NSDictionary *item;
    
    if([tableView isEqual:_tblActiveSpammers])
        item = _activeSpammers[indexPath.row];
    else
        item = _blacklist[indexPath.row];
    
    NSString *email = item[@"email"];
    BOOL selected = _selectedItems[email]?[_selectedItems[email] boolValue] : NO;
    
    [cell bindData:item selected:selected];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _selectedTab == TabSelectedActiveSpammer ? _activeSpammers[indexPath.row] : _blacklist[indexPath.row];
    
    NSString *email = item[@"email"];
    BOOL selected = _selectedItems[email]?[_selectedItems[email] boolValue] : NO;
    
    selected = !selected;
    
    [_selectedItems setObject:@(selected) forKey:email];
    
    [_currentTable reloadData];
    
    if([self selectedItemsExist])
    {
        _btnUnsubscribe.enabled = _btnKeep.enabled = YES;
        
        [_btnUnsubscribe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnKeep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        _btnUnsubscribe.enabled = _btnKeep.enabled = NO;
        
        [_btnUnsubscribe setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
        [_btnKeep setTitleColor:PM_GREY_COLOR forState:UIControlStateNormal];
    }
}

#pragma mark PMSwitchAccountVCDelegate

- (void)dismissSwitchAccountVCWithSelectedAccount:(DBNamespace *)account
{
    if(![account.email_address isEqualToString:_selectedNamespace.email_address])
    {
        _selectedNamespace = account;
        
        [self setTitleView];
        [self loadData];
    }
    
    [[KGModal sharedInstance] hideAnimated:YES];
}
@end
