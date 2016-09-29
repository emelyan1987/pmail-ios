//
//  LeftViewController.m
//  LGSideMenuControllerDemo
//
//  Created by Grigory Lutkov on 18.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "LeftViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "LeftViewCell.h"
#import "UIView+PMViewCreator.h"
#import "PMMenuHeaderView.h"
#import "PMTableViewTabBar.h"
#import "DBManager.h"
#import "PMAPIManager.h"
#import "PMFolderManager.h"


#define ALL_ACCOUNTS @"All Accounts"

@interface LeftViewController () <PMMenuHeaderViewDelegate> {
    NSMutableArray *_accounts;
    NSMutableDictionary *_folders;
    
    NSString *_selectedAccountTitle;
    NSString *_selectedFolderTitle;
    NSString *_expandedAccountTitle;
    
    NSMutableDictionary *_allUnreadCount;
}


@end

@implementation LeftViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftControllerWillShow) name:kLGSideMenuControllerWillShowLeftViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForUnreadCountChangedNotification:) name:NOTIFICATION_UNREAD_COUNT_CHANGED object:nil];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _selectedAccountTitle = _expandedAccountTitle = [[PMAPIManager shared] getRecentNamespace].email_address;
    _selectedFolderTitle = @"Inbox";
    
    [self loadMenuData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMenuData
{
    _accounts = [NSMutableArray new];
    
    [_accounts addObject:ALL_ACCOUNTS];
    [_accounts addObjectsFromArray:[[DBManager instance] getNamespaces]];
    
    [self performSelector:@selector(loadFolderData) withObject:nil afterDelay:0.1];
    
    [_tableView reloadData];
}


- (void)loadFolderData
{
    _folders = [NSMutableDictionary new];
    
    NSMutableArray *foldersForAllAccounts = [NSMutableArray new];
    [foldersForAllAccounts addObject:@{@"display_name":@"Inbox", @"name":@"inbox", @"unreads":[[PMFolderManager sharedInstance] getUnreadsForAllAccounts:@"inbox"]}];
    [foldersForAllAccounts addObject:@{@"display_name":@"Sent", @"name":@"sent", @"unreads":[[PMFolderManager sharedInstance] getUnreadsForAllAccounts:@"sent"]}];
    [foldersForAllAccounts addObject:@{@"display_name":@"Archive", @"name":@"archive", @"unreads":[[PMFolderManager sharedInstance] getUnreadsForAllAccounts:@"archive"]}];
    [foldersForAllAccounts addObject:@{@"display_name":@"Trash", @"name":@"trash", @"unreads":[[PMFolderManager sharedInstance] getUnreadsForAllAccounts:@"trash"]}];
    [foldersForAllAccounts addObject:@{@"display_name":@"Drafts", @"name":@"drafts", @"unreads":[[PMFolderManager sharedInstance] getUnreadsForAllAccounts:@"drafts"]}];
    
    [_folders setObject:foldersForAllAccounts forKey:ALL_ACCOUNTS];
    
    for(NSInteger index=1; index<_accounts.count; index++)
    {
        DBNamespace *namespace = _accounts[index];
        NSString *accountId = namespace.account_id;
        
        NSMutableArray *foldersForNamespace = [NSMutableArray new];
        
        [foldersForNamespace addObjectsFromArray:[[PMFolderManager sharedInstance] getFoldersForAccount:accountId]];
        
        [_folders setObject:foldersForNamespace forKey:namespace.email_address];
    }
}

#pragma mark -

- (void)leftControllerWillShow {
    [self loadMenuData];
}

- (void)openLeftView {
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _accounts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *accountTitle;
    if(section == 0)
        accountTitle = _accounts[section];
    else
        accountTitle = ((DBNamespace*)_accounts[section]).email_address;
    
    NSArray *foldersForAccount = _folders[accountTitle];
    return ([accountTitle isEqualToString:_expandedAccountTitle]) ? foldersForAccount.count : 0;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"folderCell"];
    
    NSString *accountTitle;
    if(indexPath.section == 0)
        accountTitle = _accounts[indexPath.section];
    else
        accountTitle = ((DBNamespace*)_accounts[indexPath.section]).email_address;
    
    NSArray *foldersForAccount = _folders[accountTitle];
    NSDictionary *folder = foldersForAccount[indexPath.row];
    [cell bindData:folder selected:[_selectedFolderTitle isEqualToString:folder[@"display_name"]]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PMMenuHeaderView *lView = [PMMenuHeaderView createView];
    [lView setDelegate:self];
    lView.tag = section;
    
    NSString *accountTitle;
    if(section==0)
    {
        accountTitle = _accounts[section];
        [lView setTitle:accountTitle forProvider:nil];
    }
    else
    {
        DBNamespace *namespace = _accounts[section];
        accountTitle = namespace.email_address;
        [lView setTitle:accountTitle forProvider:namespace.provider];
    }
    
    if([accountTitle isEqualToString:_expandedAccountTitle])
    {
        [lView expand];
    }
    else
    {
        [lView collapse];
    }
    
    [lView setSelected:([accountTitle isEqualToString:_selectedAccountTitle])];
    
    CGRect lViewFrame = CGRectMake(0, 0, tableView.frame.size.width, 52);
    lView.frame = lViewFrame;
    return lView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
    
    NSString *accountTitle;
    if(indexPath.section == 0)
        accountTitle = _accounts[indexPath.section];
    else
        accountTitle = ((DBNamespace*)_accounts[indexPath.section]).email_address;
    
    _selectedAccountTitle = accountTitle;
    NSArray *foldersForAccount = _folders[accountTitle];
    
    NSDictionary *folder = foldersForAccount[indexPath.row];
    NSString *folderName = foldersForAccount[indexPath.row][@"display_name"];
    
    _selectedFolderTitle = folderName;
    
    NSDictionary *userInfo = @{@"folder_name":folderName};
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENU_FOLDER_SELECTED object:indexPath.section==0?nil:_accounts[indexPath.section] userInfo:folder];
    
    [_tableView reloadData];
}

#pragma mark - PMMenuHeaderView delegate

- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView selectedState:(BOOL)selected {
    [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
    
    NSInteger sectionIndex = menuHeaderView.tag;
    
    if(sectionIndex == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED object:nil];
        
        _selectedAccountTitle = _accounts[sectionIndex];
    }
    else
    {        
        DBNamespace *namespace = _accounts[sectionIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED object:namespace];
        
        _selectedAccountTitle = namespace.email_address;
    }
    [_tableView reloadData];
}

- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView expanded:(BOOL)expanded
{
    NSInteger sectionIndex = menuHeaderView.tag;
    
    if(!expanded)
    {
        _expandedAccountTitle = nil;
    }
    else
    {
        if(sectionIndex == 0)
        {
            _expandedAccountTitle = _accounts[sectionIndex];
            
        }
        else
        {
            DBNamespace *namespace = _accounts[sectionIndex];
            
            _expandedAccountTitle = namespace.email_address;
        }
    }
    [_tableView reloadData];
    
}
- (void)handlerForUnreadCountChangedNotification:(NSNotification*)notification
{
    [_tableView reloadData];
}


@end
