//
//  PMMailVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailVC.h"
#import "PMMailMenuView.h"
#import "SWTableViewCell.h"
#import "DBManager.h"
#import "PMAPIManager.h"
#import "MBProgressHUD.h"
#import "PMMailTVCell.h"
#import "PMThread.h"
#import "PMLoadMoreTVCell.h"
#import "PMPreviewMailVC.h"
#import "AppDelegate.h"
#import "MainViewController.h"

#import "PMMailComposeVC.h"
#import "PMSearchMailVC.h"
#import "PMTableViewTabBar.h"
#import "UIView+PMViewCreator.h"
#import "PMMessagesTableView.h"
#import "LeftViewController.h"
#import "PMSnoozeAlertViewController.h"
#import "PMPickerViewController.h"

#import "AlertManager.h"
#import "NSMutableArray+PMThread.h"
#import "Config.h"
#import "PMRSVPManager.h"
#import "PMSettingsManager.h"
#import "PMScheduleManager.h"

#import "PMFolderManager.h"

#define CELL_IDENTIFIER @"mailCell"
#define LIMIT 50

typedef NS_ENUM(NSInteger, OffsetType) {
    OffsetTypeMails,
    OffsetTypeSocial,
    OffsetTypeReadLater,
    OffsetTypeFollowUps
};

IB_DESIGNABLE
@interface PMMailVC () <PMMailMenuViewDelegate, PMPreviewMailVCDelegate, PMTableViewTabBarDelegate, PMMessagesTableViewDelegate, PMAlertViewControllerDelegate, PMMailComposeVCDelegate> {
    CGFloat _centerX;
    __weak IBOutlet PMTableViewTabBar *_tableViewTabBar;
    
    NSInteger _pageForFolder;
    NSInteger _pageForSocial;
    NSInteger _pageForReadLater;
    NSInteger _pageForFollowUps;
    
    NSMutableArray *_mailsInFolder;
    NSMutableArray *_mailsInSocial;
    NSMutableArray *_mailsInReadLater;
    NSMutableArray *_mailsInFollowUps;
    
    NSIndexPath *_selectedIndex;
    
    PMMessagesTableView *_view1;
    PMMessagesTableView *_view2;
    PMMessagesTableView *_view3;
    PMMessagesTableView *_view4;
    
    
    selectedMessages _selectedTableType;
    
    
    NSString *_currentAccountId;
    
    NSString *_selectedFolderName;
    NSString *_selectedFolderDisplayName;
    DBNamespace *_selectedNamespace;
}

- (IBAction)searchBtnPressed:(id)sender;
- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createMailBtnPressed:(id)sender;


@property(nonatomic, strong) PMMailMenuView *mailMenu;

@property(nonatomic) IBInspectable UIColor *color;

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (nonatomic, assign) BOOL isFilter;

@end

@implementation PMMailVC

#pragma mark - PMMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedFolderName = @"inbox";
    _selectedFolderDisplayName = @"Inbox";
    
    PMAPIManager *apiManager = [PMAPIManager shared];
    
    _selectedNamespace = [apiManager getRecentNamespace];
    [apiManager setActiveNamespace:_selectedNamespace];
    _currentAccountId = _selectedNamespace.namespace_id;
    
    [self setTitleView];
    
    _selectedTableType = ImportantMessagesSelected;
    
    _mailsInFolder = [NSMutableArray array];
    _mailsInSocial = [NSMutableArray array];
    _mailsInReadLater = [NSMutableArray array];
    _mailsInFollowUps = [NSMutableArray array];
    
    _pageForFolder = 0; _pageForSocial = 0; _pageForReadLater = 0; _pageForFollowUps = 0;
    
    
    
    _view1 = [PMMessagesTableView createView];
    _view1.delegate = self;
    [self.view addSubview:_view1];
    
    _view2 = [PMMessagesTableView createView];
    _view2.delegate = self;
    [self.view addSubview:_view2];
    
    _view3 = [PMMessagesTableView createView];
    _view3.delegate = self;
    [self.view addSubview:_view3];
    
    _view4 = [PMMessagesTableView createView];
    _view4.delegate = self;
    [self.view addSubview:_view4];
    
    [self selectMessageType:ImportantMessagesSelected];
    
    [self loadMails:YES reload:NO];
    
    [self updateUnreadCount];
    [self updateAppBadgeNumber];
    _tableViewTabBar.delegate = self;
    
    [_tableViewTabBar setShow:[[PMSettingsManager instance] getEnabledImportant]];
    [self configureBlurEffect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlerForNotificationActiveAccountChanged:)
                                                 name:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlerForNotificationMenuFolderSelected:)
                                                 name:NOTIFICATION_MENU_FOLDER_SELECTED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlerForNotificationEnableImportantChanged:)
                                                 name:NOTIFICATION_ENABLE_IMPORTANT_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlerForMailScheduled:)
                                                 name:NOTIFICATION_MAIL_SCHEDULED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlerForUnreadCountChanged:)
                                                 name:NOTIFICATION_UNREAD_COUNT_CHANGED
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForNotificationEmailAddedToBlackList:) name:NOTIFICATION_EMAIL_ADDED_TO_BLACK_LIST object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForNotificationEmailRemovedFromBlackList:) name:NOTIFICATION_EMAIL_REMOVED_FROM_BLACK_LIST object:nil];
}

-(void)setTitleView
{
    NSString *title = _selectedFolderDisplayName;
    
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
    lblEmail.text = _selectedNamespace?_selectedNamespace.email_address:@"All accounts";
    lblEmail.textColor = [UIColor whiteColor];
    lblEmail.textAlignment = NSTextAlignmentCenter;
    lblEmail.numberOfLines = 1;
    lblEmail.lineBreakMode = NSLineBreakByTruncatingTail;
    lblEmail.frame = CGRectMake(0, 26, width, 15);
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    
    [headerview addSubview:lblTitle];
    [headerview addSubview:lblEmail];
    
    self.navigationItem.titleView = headerview;
    
}

- (void)updateUnreadCount
{
    NSInteger unreadsForFolder = 0, unreadsForSocial = 0, unreadsForClutter = 0, unreadsForReminder = 0;
    
    PMFolderManager *folderManager = [PMFolderManager sharedInstance];
    if(_selectedNamespace)
    {
        NSString *accountId = _selectedNamespace.account_id;
        unreadsForFolder = [[folderManager getUnreadsForAccount:accountId folderName:_selectedFolderDisplayName] integerValue];
        unreadsForSocial = [[folderManager getUnreadsForAccount:accountId folderName:@"Social"] integerValue];
        unreadsForClutter = [[folderManager getUnreadsForAccount:accountId folderName:@"Read Later"] integerValue];
        
        unreadsForReminder = [self getUnreadsCountForReminder];
    }
    else
    {
        unreadsForFolder = [[folderManager getUnreadsForAllAccounts:_selectedFolderDisplayName] integerValue];
        unreadsForSocial = [[folderManager getUnreadsForAllAccounts:@"Social"] integerValue];
        unreadsForClutter = [[folderManager getUnreadsForAllAccounts:@"Read Later"] integerValue];
        
        unreadsForReminder = [self getUnreadsCountForReminder];
        
    }
    
    
    switch (_selectedTableType) {
        case ImportantMessagesSelected:
            [[AppDelegate sharedInstance].tabBarController updateUnreadsCount:unreadsForFolder];
            break;
        case SocialMessagesSelected:
            [[AppDelegate sharedInstance].tabBarController updateUnreadsCount:unreadsForSocial];
            break;
        case ReadLaterMessagesSelected:
            [[AppDelegate sharedInstance].tabBarController updateUnreadsCount:unreadsForClutter];
            break;
        case FollowUpsMessagesSelected:
            [[AppDelegate sharedInstance].tabBarController updateUnreadsCount:unreadsForReminder];
            break;
            
        default:
            break;
    }
}

- (NSInteger)getUnreadsCountForReminder
{
    NSInteger count = 0;
    for(PMThread *mail in _mailsInFollowUps)
    {
        if(mail.isUnread) count ++;
    }
    
    return count;
}
- (void)selectMessageType:(selectedMessages)messageType
{
    PMMessagesTableView *currentView = [self currentTableView];
    PMMessagesTableView *newView;
    
    NSInteger unreadsCount = 0;
    
    PMFolderManager *folderManager = [PMFolderManager sharedInstance];
    switch (messageType)
    {
        case ImportantMessagesSelected:
        {
            newView = _view1;
            if(_selectedNamespace)
            {
                NSString *accountId = _selectedNamespace.account_id;
                unreadsCount = [[folderManager getUnreadsForAccount:accountId folderName:@"Inbox"] integerValue];
            }
            else
            {
                unreadsCount = [[folderManager getUnreadsForAllAccounts:@"Inbox"] integerValue];
            }
        }
            break;
        case SocialMessagesSelected:
        {
            if(_selectedNamespace)
            {
                NSString *accountId = _selectedNamespace.account_id;
                unreadsCount = [[folderManager getUnreadsForAccount:accountId folderName:@"Social"] integerValue];
            }
            else
            {
                unreadsCount = [[folderManager getUnreadsForAllAccounts:@"Social"] integerValue];
            }
            newView = _view2;
        }
            break;
        case ReadLaterMessagesSelected:
        {
            if(_selectedNamespace)
            {
                NSString *accountId = _selectedNamespace.account_id;
                unreadsCount = [[folderManager getUnreadsForAccount:accountId folderName:@"Read Later"] integerValue];
            }
            else
            {
                unreadsCount = [[folderManager getUnreadsForAllAccounts:@"Read Later"] integerValue];
            }
            newView = _view3;
        }
            break;
        case FollowUpsMessagesSelected:
        {
            if(_selectedNamespace)
            {
                unreadsCount = [self getUnreadsCountForReminder];
                
            }
            else
            {
                unreadsCount = [self getUnreadsCountForReminder];
            }
            newView = _view4;
        }
            break;
    }
    [[AppDelegate sharedInstance].tabBarController updateUnreadsCount:unreadsCount];
    
    CGRect mainFrame = CGRectMake(0, 64+_tableViewTabBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _tableViewTabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 64);
    CGRect currentViewStartFrame = currentView.frame;
    CGRect currentViewEndFrame, newViewStartFrame;
    CGRect newViewEndFrame = mainFrame;
    
    if(messageType>_selectedTableType)
    {
        currentViewEndFrame = CGRectMake(mainFrame.origin.x - mainFrame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
        newViewStartFrame = CGRectMake(mainFrame.origin.x+mainFrame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    }
    else
    {
        currentViewEndFrame = CGRectMake(mainFrame.origin.x + mainFrame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
        newViewStartFrame = CGRectMake(mainFrame.origin.x-mainFrame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    }
    
    _view1.frame = currentViewEndFrame; _view2.frame = currentViewEndFrame; _view3.frame = currentViewEndFrame; _view4.frame = currentViewEndFrame;
    
    currentView.frame = currentViewStartFrame;
    newView.frame = newViewStartFrame;
    
    _selectedTableType = messageType;
    [UIView animateWithDuration:0.3 animations:^{
        currentView.frame = currentViewEndFrame;
        newView.frame = newViewEndFrame;
    } completion:^(BOOL finished) {
        
        [[self currentTableView] reloadMessagesTableView];
    }];
    
    
}
#pragma mark - Configure Blur
-(void)configureBlurEffect {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    self.blurEffectView.frame = self.view.bounds;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MENU_FOLDER_SELECTED object:nil];
}

- (void)handlerForNotificationActiveAccountChanged:(NSNotification*)notification {
    
    _selectedNamespace = [notification object];
    
    if(_selectedNamespace)
    {
        _currentAccountId = _selectedNamespace.namespace_id;
        [[PMAPIManager shared] setActiveNamespace:_selectedNamespace];
    }
    
    
    [self updateUnreadCount];
    
    _selectedFolderName = @"Inbox";
    
    [self loadMails:YES reload:NO];
}

- (void)handlerForNotificationMenuFolderSelected:(NSNotification *)notification
{
    _selectedNamespace = [notification object];
    
    
    if(_selectedNamespace)
    {
        _currentAccountId = _selectedNamespace.namespace_id;
        [[PMAPIManager shared] setActiveNamespace:_selectedNamespace];
        
    }
    
    NSDictionary *folder = notification.userInfo;
    NSString *folderDisplayName = folder[@"display_name"];
    NSString *folderName = folder[@"name"];
    
    _selectedFolderDisplayName = folderDisplayName;
    _selectedFolderName = !folderName || folderName.length==0 || [folderName isEqualToString:@"user_created_folder"] ? folderDisplayName : folderName;
    
    DLog(@"Selected Folder Name:%@", _selectedFolderName);
    
    if ([[_selectedFolderName lowercaseString] isEqualToString:@"inbox"])
    {
        [_tableViewTabBar setShow:[[PMSettingsManager instance] getEnabledImportant]];
        [_tableViewTabBar selectMessages:ImportantMessagesSelected animated:YES];
    }
    else
    {
        [_tableViewTabBar setShow:NO];
        [_tableViewTabBar selectMessages:ImportantMessagesSelected animated:YES];
    }
    [self loadMails:YES reload:NO];
    
    [self updateUnreadCount];
}

- (void)loadMails:(BOOL)update reload:(BOOL)reload
{
    if(!reload)
    {
        _pageForFolder = 0; _pageForSocial = 0; _pageForReadLater = 0; _pageForFollowUps = 0;
        
        [_mailsInFolder removeAllObjects];
        [_mailsInSocial removeAllObjects];
        [_mailsInReadLater removeAllObjects];
        [_mailsInFollowUps removeAllObjects];
        
        [[self currentTableView] initializeMessageTableView];
    }
    
    if ([[_selectedFolderName lowercaseString] isEqualToString:@"inbox"])
    {
        [self loadMailsInFolder:@"inbox" update:update reload:reload];
        [self loadMailsInSocial:update reload:reload];
        [self loadMailsInReadLater:update reload:reload];
        [self loadMailsInFollowUps:update];
    }
    else if([[_selectedFolderName lowercaseString] isEqualToString:@"drafts"])
    {
        [self loadMailsInDrafts];
    }
    else
    {
        [self loadMailsInFolder:_selectedFolderName update:update reload:reload];
    }
    
    [self setTitleView];
}
- (void)setColor:(UIColor *)color {
    self.view.backgroundColor = color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBarHidden = NO;
    
    
    //[[self currentTableView] reloadMessagesTableView];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Your layout logic here
}

- (void)reloadMessagesTableView:(PMMessagesTableView*)tableView
{
    [tableView reloadMessagesTableView];
}
- (void)updateMailsNextPage:(BOOL)nextPage
{
    if (_selectedTableType == ImportantMessagesSelected)
    {
        if(!nextPage)
        {
            _pageForFolder = 0;
            [_mailsInFolder removeAllObjects];
        }
        
        if([[_selectedFolderName lowercaseString] isEqualToString:@"drafts"])
            [self loadMailsInDrafts];
        else
            [self loadMailsInFolder:_selectedFolderName update:YES reload:NO];
    }
    else if (_selectedTableType == SocialMessagesSelected)
    {
        if(!nextPage)
        {
            _pageForSocial = 0;
            [_mailsInSocial removeAllObjects];
        }
        [self loadMailsInSocial:YES reload:NO];
    }
    else if (_selectedTableType == ReadLaterMessagesSelected)
    {
        if(!nextPage)
        {
            _pageForReadLater = 0;
            [_mailsInReadLater removeAllObjects];
        }
        [self loadMailsInReadLater:YES reload:NO];
    }
    else if (_selectedTableType == FollowUpsMessagesSelected)
    {
        [self loadMailsInFollowUps:YES];
    }
}

- (void)loadMailsInDrafts
{
    if(_selectedNamespace)
    {
        [self loadMailsInDraftsForNamespace:_selectedNamespace];
    }
    else
    {
        for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
        {
            [self loadMailsInDraftsForNamespace:namespace];
        }
    }
}

- (void)loadMailsInDraftsForNamespace:(DBNamespace*)namespace
{
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Loading mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
    [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id parameters:nil path:@"/drafts" completion:^(id data, id error, BOOL success) {
        [AlertManager hideStatusBar:issuedTime];
        
        if(success && data && [data isKindOfClass:[NSArray class]])
            _mailsInFolder = data;
        else
            _mailsInFolder = [NSMutableArray new];
        [self reloadMessagesTableView:_view1];
    }];
}

- (void)loadMailsInFolder:(NSString*)folder update:(BOOL)update reload:(BOOL)reload
{
    if(!reload)
        _pageForFolder++;
    
    if(_selectedNamespace)
    {
        [self loadMailsInFolder:folder forNamespace:_selectedNamespace update:update];
    }
    else
    {
        for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
        {
            [self loadMailsInFolder:folder forNamespace:namespace update:update];
        }
    }
}
- (void)loadMailsInFolder:(NSString*)folder forNamespace:(DBNamespace*)namespace update:(BOOL)update
{
    
    DLog(@"Email address: %@", namespace.email_address);
    NSArray *mails = [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:folder offset:(_pageForFolder-1)*LIMIT limit:LIMIT];
    
    for(PMThread *model in mails)
    {
        if(![folder isEqualToString:@"Social"] && [model belongsToFolder:@"Social"]) continue;
        if(![folder isEqualToString:@"Read Later"] && [model belongsToFolder:@"Read Later"]) continue;
        if(![folder isEqualToString:@"Black Hole"] && [model belongsToFolder:@"Black Hole"]) continue;
        
        if(![_mailsInFolder isContainMail:model])
            [_mailsInFolder addMail:model];
    }
    [self reloadMessagesTableView:_view1];
    
    if(update)
    {
        NSDate *issuedTime = [NSDate date];
        [AlertManager showStatusBarWithMessage:@"Updating mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        
        [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:folder offset:(_pageForFolder-1)*LIMIT limit:LIMIT completion:^(id data, id error, BOOL success) {
            [AlertManager hideStatusBar:issuedTime];
            
            if(success && [data isKindOfClass:[NSArray class]])
            {
                NSArray *mails = data;
                for(PMThread *model in mails)
                {
                    if(![folder isEqualToString:@"Social"] && [model belongsToFolder:@"Social"]) continue;
                    if(![folder isEqualToString:@"Read Later"] && [model belongsToFolder:@"Read Later"]) continue;
                    if(![folder isEqualToString:@"Black Hole"] && [model belongsToFolder:@"Black Hole"]) continue;
                    
                    if(![_mailsInFolder isContainMail:model])
                        [_mailsInFolder addMail:model];
                    
                    if([_mailsInFolder changedMail:model])
                    {
                        [_mailsInFolder changeMail:model];
                    }
                }
                [self reloadMessagesTableView:_view1];
            }
            
        }];
        
    }
    
}


- (void)loadMailsInSocial:(BOOL)update reload:(BOOL)reload
{
    if(!reload)
        _pageForSocial++;
    
    if(_selectedNamespace)
    {
        [self loadMailsInSocialForNamespace:_selectedNamespace update:update];
    }
    else
    {
        for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
        {
            [self loadMailsInSocialForNamespace:namespace update:update];
        }
    }
}
- (void)loadMailsInSocialForNamespace:(DBNamespace *)namespace update:(BOOL)update
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        NSArray *mails = [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:@"Social" offset:(_pageForSocial-1)*LIMIT limit:LIMIT];
        for(PMThread *model in mails)
        {
            if([model belongsToFolder:@"Read Later"] || [model belongsToFolder:@"Black Hole"]) continue;
            
            if(![_mailsInSocial isContainMail:model])
                [_mailsInSocial addMail:model];
            if([_mailsInSocial changedMail:model])
                [_mailsInSocial changeMail:model];
        }
        [self reloadMessagesTableView:_view2];
        
        
        if(update)
        {
            NSDate *issuedTime = [NSDate date];
            [AlertManager showStatusBarWithMessage:@"Updating social mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
            
            [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:@"Social" offset:(_pageForSocial-1)*LIMIT limit:LIMIT completion:^(id data, id error, BOOL success) {
                
                [AlertManager hideStatusBar:issuedTime];
                
                if(success && [data isKindOfClass:[NSArray class]])
                {
                    NSArray *mails = [self deleteReadLaterMessagesFromArray:data];
                    for(PMThread *model in mails)
                    {
                        if([model belongsToFolder:@"Read Later"] || [model belongsToFolder:@"Black Hole"]) continue;
                        
                        if(![_mailsInSocial isContainMail:model])
                            [_mailsInSocial addMail:model];
                        
                        if([_mailsInSocial changedMail:model])
                        {
                            [_mailsInSocial changeMail:model];
                        }
                    }
                    [self reloadMessagesTableView:_view2];
                }
                
            }];
        }
        
    });
}
- (void)loadMailsInReadLater:(BOOL)update reload:(BOOL)reload
{
    if(!reload)
        _pageForReadLater ++;
    
    if(_selectedNamespace)
    {
        [self loadMailsInReadLaterForNamespace:_selectedNamespace update:update];
    }
    else
    {
        for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
        {
            [self loadMailsInReadLaterForNamespace:namespace update:update];
        }
    }
}
- (void)loadMailsInReadLaterForNamespace:(DBNamespace *)namespace update:(BOOL)update
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        NSArray *mails = [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:@"Read Later" offset:(_pageForReadLater-1)*LIMIT limit:LIMIT];
        
        for(PMThread *model in mails)
        {
            if([model belongsToFolder:@"Social"] || [model belongsToFolder:@"Black Hole"]) continue;
            
            if(![_mailsInReadLater isContainMail:model])
                [_mailsInReadLater addMail:model];
            if([_mailsInReadLater changedMail:model])
                [_mailsInReadLater changeMail:model];
        }
        [self reloadMessagesTableView:_view3];
        
        if(update)
        {
            NSDate *issuedTime = [NSDate date];
            [AlertManager showStatusBarWithMessage:@"Updating clutter mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
            
            [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:@"Read Later" offset:(_pageForReadLater-1)*LIMIT limit:LIMIT completion:^(id data, id error, BOOL success) {
                
                [AlertManager hideStatusBar:issuedTime];
                
                if(success && [data isKindOfClass:[NSArray class]])
                {
                    NSArray *mails = data;
                    for(PMThread *model in mails)
                    {
                        if([model belongsToFolder:@"Social"] || [model belongsToFolder:@"Black Hole"]) continue;
                        
                        if(![_mailsInReadLater isContainMail:model])
                            [_mailsInReadLater addMail:model];
                        
                        if([_mailsInReadLater changedMail:model])
                        {
                            [_mailsInReadLater changeMail:model];
                        }
                    }
                    [self reloadMessagesTableView:_view3];
                }
            }];
        }
        
        
    });
}
- (void)loadMailsInFollowUps:(BOOL)reload
{
    if(_selectedNamespace)
    {
        [self loadMailsInFollowUpsForNamespace:_selectedNamespace];
    }
    else
    {
        for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
        {
            [self loadMailsInFollowUpsForNamespace:namespace];
        }
    }
}
- (void)loadMailsInFollowUpsForNamespace:(DBNamespace*)namespace
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSArray *mails = [[PMAPIManager shared] getSnoozedThreadsForAccount:namespace.account_id];
        
        for(PMThread *model in mails)
        {
            if(![_mailsInFollowUps isContainMail:model])
                [_mailsInFollowUps addMail:model];
            
            if([_mailsInFollowUps changedMail:model])
            {
                [_mailsInFollowUps changeMail:model];
            }
        }
        
        [self reloadMessagesTableView:_view4];
        
        /*NSString *folderID = [PMStorageManager getScheduledFolderIdForAccount:namespace.namespace_id];
        if(folderID) {
            NSDate *issuedTime = [NSDate date];
            [AlertManager showStatusBarWithMessage:@"Updating mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
            
            NSNumber *offsetNum = [_offsetFollowUps objectForKey:namespace.account_id];
            NSArray *dbMailModels = [[PMAPIManager shared] getThreadsWithAccount:[PMAPIManager shared].namespaceId limit:COUNT_MESSAGES offset:offsetNum?[offsetNum integerValue]:0 filter:folderID completion:^(id data, id error, BOOL success) {
                
                [AlertManager hideStatusBar:issuedTime];
                
                //[_mailsInFollowUps addObjectsFromArray:data];
                NSArray *mails = (NSArray*)data;//[self deleteReadLaterMessagesFromArray:data];
                for(PMInboxMailModel *model in mails)
                {
                    if(![_mailsInFollowUps isContainMail:model])
                        [_mailsInFollowUps addMail:model];
                    
                    if([_mailsInFollowUps changedMail:model])
                    {
                        [_mailsInFollowUps changeMail:model];
                    }
                }
                [[self currentTableView] reloadMessagesTableView];
                [self increaseOffsetForAccount:namespace.account_id offsetType:OffsetTypeFollowUps];
            }];
            
            for(PMInboxMailModel *model in dbMailModels)
            {
                if(![_mailsInFollowUps isContainMail:model])
                    [_mailsInFollowUps addMail:model];
                if([_mailsInFolder changedMail:model])
                    [_mailsInFolder changeMail:model];
            }
            [[self currentTableView] reloadMessagesTableView];
        }*/
    });
}

- (void)updateAppBadgeNumber
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        PMFolderManager *folderManager = [PMFolderManager sharedInstance];
        NSInteger unreadsForImportant = [[folderManager getUnreadsForAllAccounts:@"Inbox"] integerValue];
        NSInteger unreadsForSocial = [[folderManager getUnreadsForAllAccounts:@"Social"] integerValue];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadsForImportant/* + unreadsForSocial*/;
    });
    
}

- (void)handlerForUnreadCountChanged:(NSNotification*)notification
{
    [self updateAppBadgeNumber];
    
    [self updateUnreadCount];
}
#pragma mark - IBAction selectors

- (void)searchBtnPressed:(id)sender {    
    PMSearchMailVC *lNewSearchMailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSearchMailVC"];
    
    UINavigationController *lNavControler = [[UINavigationController alloc] initWithRootViewController:lNewSearchMailVC];
    
    [self.tabBarController presentViewController:lNavControler animated:YES completion:nil];
}

- (void)menuBtnPressed:(id)sender {
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
    
}

- (void)createMailBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    PMDraftModel *lDraft = [PMDraftModel new];
    lNewMailComposeVC.draft = lDraft;
    lNewMailComposeVC.delegate = self;
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}


#pragma mark PMMailComposeVCDelegate implementation

- (void)PMMailComposeVCDelegate:(PMMailComposeVC *)controller didFinishWithResult:(PMMailComposeResult)result error:(NSError *)error
{
    if(result == PMMailComposeResultSent)
    {
        if([[_selectedFolderName lowercaseString] isEqualToString:@"sent"])
        {
            [self performSelector:@selector(updateSentMails) withObject:nil afterDelay:5];
        }
        else if([[_selectedFolderName lowercaseString] isEqualToString:@"drafts"])
        {
            [self performSelector:@selector(loadMailsInDrafts) withObject:nil afterDelay:5];
        }
    }
    else if(result == PMMailComposeResultSaved)
    {
        if([[_selectedFolderName lowercaseString] isEqualToString:@"drafts"])
        {
            [self performSelector:@selector(loadMailsInDrafts) withObject:nil afterDelay:5];
        }
    }
}

- (void)updateSentMails
{
    _pageForFolder = 0;
    [self loadMailsInFolder:@"sent" update:YES reload:NO];
}
#pragma mark - Additional methods

- (PMMessagesTableView *)currentTableView {
    
    PMMessagesTableView *lTableView;
    
    switch (_selectedTableType) {
        case ImportantMessagesSelected:
            lTableView = _view1;
            break;
        case SocialMessagesSelected:
            lTableView = _view2;
            break;
        case ReadLaterMessagesSelected:
            lTableView = _view3;
            break;
        case FollowUpsMessagesSelected:
            lTableView = _view4;
            break;
            
    }
    return lTableView;
}



- (PMMailMenuView *)mailMenu {
    if (_mailMenu == nil) {
        _mailMenu = [PMMailMenuView createView];
        [_mailMenu setDelegate:self];
    }
    return _mailMenu;
}

#pragma mark - PMMessageTableView delegate

- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView *)messagesTableVie
{
    [self updateMailsNextPage:NO];
}
- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView *)messagesTableVie nextPage:(BOOL)nextPage
{
    [self updateMailsNextPage:YES];
}

- (void)PMMessagesTableViewDelegate:(PMMessagesTableView *)messagesTableView selectedMessage:(PMThread *)messageModel selectedMessageArray:(NSArray *)messageArray
{
    if([_selectedFolderName isEqualToString:@"drafts"])
    {
        [[PMAPIManager shared] getDraftWithId:messageModel.id forAccount:messageModel.accountId completion:^(id data, id error, BOOL success) {
            
            PMDraftModel *lDraft = nil;
            if(success && [data isKindOfClass:[NSDictionary class]])
            {
                lDraft = [PMDraftModel new];
                
                NSDictionary *item = data;
                
                lDraft.id = item[@"id"];
                lDraft.to = item[@"to"];
                lDraft.cc = item[@"cc"];
                lDraft.bcc = item[@"bcc"];
                lDraft.subject = item[@"subject"];
                lDraft.body = item[@"body"];
                lDraft.version = item[@"version"];
            }
            
            PMMailComposeVC *mailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
            
            mailComposeVC.draft = lDraft;
            mailComposeVC.delegate = self;
            
            [self.navigationController presentViewController:mailComposeVC animated:YES completion:nil];
        }];
    }
    else
    {
        PMPreviewMailVC *lNewMailPreviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMPreviewMailVC"];
        lNewMailPreviewVC.delegate = self;
        lNewMailPreviewVC.inboxMailModel = messageModel;
        
        lNewMailPreviewVC.inboxMailArray = messageArray;//[self selectedDataSource];
        lNewMailPreviewVC.selectedMailIndex = [messageArray indexOfObject:messageModel];//[[self selectedDataSource] indexOfObject:messageModel];
        
        [self.navigationController pushViewController:lNewMailPreviewVC animated:YES];
    }
    
}

- (NSArray *)PMMessagesTableViewDelegateGetData:(PMMessagesTableView *)messagesTableView {
    return [self selectedDataSource];
}

-(void)PMMessagesTableViewDelegateShowAlert:(PMMessagesTableView *)messagesTableView inboxMailModel:(PMThread*)mailModel showAutoAsk:(BOOL)autoAsk {
    
    PMSnoozeAlertViewController *alert = [[PMSnoozeAlertViewController alloc] init];
    alert.view.backgroundColor = [UIColor clearColor];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.inboxMailModel = mailModel;
    alert.isNotifyMe = autoAsk;
    alert.delegate = self;
    [self presentViewController:alert animated:YES completion:nil];

    [UIView animateWithDuration:0.4 animations:^{

        [self.view addSubview:self.blurEffectView];

        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.tabBarController.tabBar.hidden = YES;
    }];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableSwipe" object:nil];
    
}

- (void)didTapRSVPButton:(id)sender model:(PMThread *)model
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        //[[self currentTableView] removeInboxMailModel:model];
        
        NSString *messageId = model.messageIds[0];
        [[PMRSVPManager sharedInstance] sendRSVPByMessageId:messageId type:RSVP_TYPE_ACCEPT completion:^(id data, NSError *error) {
            if(error==nil)
            {
                [[PMAPIManager shared] deleteThread:model completion:^(id data, id error, BOOL success) {
                    if(success) {
                        [[self selectedDataSource] removeObject:model];
                        [[self currentTableView] reloadMessagesTableView];
                    }
                }];
            }
        }];
    }];
    UIAlertAction *actionTentative = [UIAlertAction actionWithTitle:@"Tentative" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        //[[self currentTableView] removeInboxMailModel:model];
        
        NSString *messageId = model.messageIds[0];
        [[PMRSVPManager sharedInstance] sendRSVPByMessageId:messageId type:RSVP_TYPE_TENTATIVE completion:^(id data, NSError *error) {
            if(error==nil)
            {
                [[PMAPIManager shared] deleteThread:model completion:^(id data, id error, BOOL success) {
                    if(success) {
                        [[self selectedDataSource] removeObject:model];
                        [[self currentTableView] reloadMessagesTableView];
                    }
                }];
            }
        }];
    }];
    UIAlertAction *actionDecline = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        //[[self currentTableView] removeInboxMailModel:model];
        
        NSString *messageId = model.messageIds[0];
        [[PMRSVPManager sharedInstance] sendRSVPByMessageId:messageId type:RSVP_TYPE_DECLINE completion:^(id data, NSError *error) {
            if(error==nil)
            {
                [[PMAPIManager shared] deleteThread:model completion:^(id data, id error, BOOL success) {
                    if(success) {
                        [[self selectedDataSource] removeObject:model];
                        [[self currentTableView] reloadMessagesTableView];
                    }
                }];
            }
        }];
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

- (void)didTapUnsubscribeButton:(id)sender model:(PMThread *)model
{
    [AlertManager showProgressBarWithTitle:nil view:self.view];
    [[PMAPIManager shared] unsubscribeThread:model completion:^(id data, id error, BOOL success)
     {
         [AlertManager hideProgressBar];
         
         if(success)
         {
             NSArray *emails = [model getParticipantEmailsExcludingMe];
             if(emails && emails.count)
             {
                 
                 NSString *title = [NSString stringWithFormat:@"Unsubscribe from %@", [emails componentsJoinedByString:@", "]];
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
                         }
                     }];
                 }];
                 
                 [alert addAction:cancel];
                 [alert addAction:ok];
                 
                 [self presentViewController:alert animated:YES completion:nil];
             }
         }
     }];
    
}

- (void)didThreadArchived:(PMThread *)thread
{
    [[self selectedDataSource] removeObject:thread];
    [[self currentTableView] reloadMessagesTableView];
    
    if(thread.isUnread)
    {
        PMFolderManager *folderManager = [PMFolderManager sharedInstance];
        NSString *archiveFolderId = [folderManager getFolderIdForAccount:thread.accountId folderName:@"Archive"];
        [folderManager increaseUnreadsForFolder:archiveFolderId];
        
        for(NSDictionary *folder in thread.folders)
        {
            [folderManager decreaseUnreadsForFolder:folder[@"id"]];
        }
    }
}
- (selectedMessages)getMessagesType {
    
    return _selectedTableType;
}

#pragma mark - PMAlertViewControllerDelegate

- (void)didScheduleWithDateType:(ScheduleDateType)dateType date:(NSDate *)date autoAsk:(NSInteger)autoAsk
{
    [UIView animateWithDuration:0.4 animations:^{

        self.tabBarController.tabBar.userInteractionEnabled = YES;

        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
    }];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableSwipe" object:nil];
    
    [[self currentTableView] reloadMessagesTableView];
}

- (void)didCancelSchdule
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        
        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
    }];
    [self.navigationController setNavigationBarHidden:NO animated:NO];    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableSwipe" object:nil];
    
    [[self currentTableView] reloadMessagesTableView];
}

#pragma mark - PMPreviewMailVC delegate

- (void)PMPreviewMailVCDelegateAction:(PMPreviewMailVCTypeAction)typeAction mail:(PMThread *)model
{
    //[self performSelector:@selector(reloadMails) withObject:nil afterDelay:3];
    //[self loadMails:NO reload:YES];
    
    
    if(typeAction==PMPreviewMailVCTypeActionArchive || typeAction==PMPreviewMailVCTypeActionDelete || typeAction==PMPreviewMailVCTypeActionMove || typeAction==PMPreviewMailVCTypeActionUnsubscribe || typeAction==PMPreviewMailVCTypeActionMarkUnimportant || typeAction==PMPreviewMailVCTypeActionMarkImportant)
    {
        [[self selectedDataSource] removeObject:model];
        [[self currentTableView] reloadMessagesTableView];
    }
    else if(typeAction==PMPreviewMailVCTypeActionMarkRead || typeAction==PMPreviewMailVCTypeActionMarkUnread)
    {
        [[self currentTableView] reloadMessagesTableView];
    }
}

- (void)reloadMails
{
    [self loadMails:NO reload:NO];
}
#pragma mark PMTableViewTabBarDelegate implementation
- (void)messagesDidSelect:(selectedMessages)messages {
    
    [self selectMessageType:messages];
    
}

- (void)didPressedFilterBtn:(id)sender
{
    if(!self.isFilter)
    {
        [self showFilterMenu:sender];
    }
    else
    {
        self.isFilter = NO;
        [_tableViewTabBar.filterBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        
        [[self currentTableView] clearFilter];
    }
}


-(void)showFilterMenu:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionUnread = [UIAlertAction actionWithTitle:@"Unread" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        self.isFilter = YES;
        [_tableViewTabBar.filterBtn setImage:[UIImage imageNamed:@"closeIcon_gray"] forState:UIControlStateNormal];
        
        [[self currentTableView] filterMessagesWithType:@"unread"];
    }];
    UIAlertAction *actionFlagged = [UIAlertAction actionWithTitle:@"Flagged" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        self.isFilter = YES;
        [_tableViewTabBar.filterBtn setImage:[UIImage imageNamed:@"closeIcon_gray"] forState:UIControlStateNormal];
        
        [[self currentTableView] filterMessagesWithType:@"flagged"];
    }];
    UIAlertAction *actionAttachments = [UIAlertAction actionWithTitle:@"Attachments" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
    
        self.isFilter = YES;
        [_tableViewTabBar.filterBtn setImage:[UIImage imageNamed:@"closeIcon_gray"] forState:UIControlStateNormal];
        
        [[self currentTableView] filterMessagesWithType:@"attachments"];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionUnread];
    [alert addAction:actionFlagged];
    [alert addAction:actionAttachments];
    [alert addAction:actionCancel];
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Private methods

- (NSMutableArray *)deleteReadLaterMessagesFromArray:(NSMutableArray *)array {
    NSMutableArray *lNewArray = [NSMutableArray array];
    
    for (int i = 0; i < array.count; i++){
        if (![[array objectAtIndex:i] isReadLater]) {
            [lNewArray addMail:[array objectAtIndex:i]];
        }
    }
    
    return lNewArray;
}

- (NSMutableArray *)selectedDataSource {
    
    if (_selectedTableType == ImportantMessagesSelected)
    {
        return _mailsInFolder;
    }
    else if (_selectedTableType == SocialMessagesSelected)
    {
        return _mailsInSocial;
    }
    else if (_selectedTableType == ReadLaterMessagesSelected)
    {
        return _mailsInReadLater;
    }
    else if (_selectedTableType == FollowUpsMessagesSelected)
    {
        return _mailsInFollowUps;
    }
    
    return nil;
}

#pragma mark - Animation Stuff 

-(void)animateAlpha:(CGFloat)alpha {
    
    self.view.alpha = alpha;
    self.navigationController.view.alpha = alpha;
    self.tabBarController.tabBar.alpha = alpha;

}


#pragma mark enable important changed notification handler

-(void)handlerForNotificationEnableImportantChanged:(NSNotification*)notification
{
    [_tableViewTabBar setShow:[[PMSettingsManager instance] getEnabledImportant]];
    [_tableViewTabBar selectMessages:ImportantMessagesSelected animated:YES];
}

#pragma mark handler for update reminder and snoozed list

-(void)handlerForMailScheduled:(NSNotification*)notification
{
    [self loadMailsInFollowUpsForNamespace:_selectedNamespace];
}

- (void)handlerForNotificationEmailAddedToBlackList:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self loadMails:NO reload:YES];
    });
}
- (void)handlerForNotificationEmailRemovedFromBlackList:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadMails:NO reload:YES];
    });
}
@end
