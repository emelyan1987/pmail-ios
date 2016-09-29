//
//  PMSettigsVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSettingsTVC.h"
#import "PMLoginVC.h"
#import "DBManager.h"
#import "UIViewController+PMStoryboard.h"
#import "PMAPIManager.h"
#import "MBProgressHUD.h"
#import "PMLoginVC.h"
#import "DBAccount.h"
#import "PMSettingsManager.h"
#import "PMDefaultEmailTVC.h"
#import "PMDefaultCalendarTVC.h"
#import "PMWeekStartTVC.h"
#import "PMOpenLinksWithTVC.h"
#import "PMSettingsSwitchTVCell.h"
#import "PMSetSignatureTVC.h"
#import "PMSetSwipeOptionsTVC.h"
#import "PMSetNotificationsTVC.h"
#import "AlertManager.h"
#import "PMAccountManager.h"
#import "Config.h"
#import "AppDelegate.h"


#import <DropboxSDK/DropboxSDK.h>
#import <BoxContentSDK/BOXContentSDK.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <OneDriveSDK/OneDriveSDK.h>

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "PMMailComposeVC.h"
#import <evernote-cloud-sdk-ios/ENSDKAdvanced.h>
#import "PMSFAuthorizingVC.h"

#import "DBManager.h"

#define DYNAMIC_SECTION 0
#define CELL_IDENTIFIER @"journalTVCell"

@interface PMSettingsTVC () <PMLoginVCDelegate, PMDefaultEmailTVCDelegate, PMDefaultCalendarTVCDelegate, PMWeekStartTVCDelegate, PMOpenLinksWithTVCDelegate, PMSettingsSwitchTVCellDelegate, PMSetSignatureTVCDelegate, PMSetSwipeOptionsTVCDelegate, MFMessageComposeViewControllerDelegate, PMSFAuthorizingVCDelegate> {
    NSIndexPath *_selectedIndex;
    
    NSArray *_sections;
    NSMutableDictionary *_items;
    
    NSArray *_accounts;
}
- (IBAction)addAccountBtnPressed:(id)sender;
@end

@implementation PMSettingsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self buildTableData];
    
    [self.tableView reloadData];
}

- (void)buildTableData
{
    _sections = @[@"ACCOUNTS", @"CONNECTIONS", @"MAIL", @"CALENDAR", @"PREFERENCES", @"MORE"];
    _items = [[NSMutableDictionary alloc] init];
    
    [self buildAccountData];
    
    [_items setObject:@[@"salesforceCell"] forKey:@"CONNECTIONS"];
    [_items setObject:@[@"mailNotificationsCell", @"mailDefaultCell", @"signatureCell", @"swipeOptionsCell", @"importantCell", @"organizeMailByThreadCell"] forKey:@"MAIL"];
    [_items setObject:@[@"calendarNotificationsCell", @"calendarDefaultCell", @"weekStartCell"] forKey:@"CALENDAR"];
    [_items setObject:@[@"openLinksWithCell"] forKey:@"PREFERENCES"];
    [_items setObject:@[@"tellAboutPlanckCell"] forKey:@"MORE"];
    
}
- (void)buildAccountData
{
    _accounts = [[DBManager instance] getAccounts];
    NSMutableArray *accountItems = [NSMutableArray new];
    for(NSInteger i=0; i<_accounts.count; i++)
        [accountItems addObject:@"accountCell"];
    [accountItems addObject:@"addAccountCell"];
    
    [_items setObject:accountItems forKey:@"ACCOUNTS"];
}
- (void)addAccountBtnPressed:(id)sender {
    PMLoginVC *lNewLoginVC = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"PMLoginVC"];
    [lNewLoginVC setAdditionalAccoutn:YES];
    [lNewLoginVC setDelegate:self];
    
    [self presentViewController:lNewLoginVC animated:YES completion:nil];
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionKey = [_sections objectAtIndex:section];
    NSArray *itemsInSection = [_items objectForKey:sectionKey];
    if(sectionKey) return [itemsInSection count];
    
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.textAlignment = NSTextAlignmentCenter;
    sectionHeader.font = [UIFont systemFontOfSize:15];
    sectionHeader.textColor = [UIColor darkGrayColor];
    
    sectionHeader.text = _sections[section];
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSString *sectionKey = [_sections objectAtIndex:indexPath.section];
    NSArray *itemsInSection = [_items objectForKey:sectionKey];
    
    NSString *cellIdentifier = [itemsInSection objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if([cellIdentifier isEqualToString:@"accountCell"])
    {
        DBAccount *account = [_accounts objectAtIndex:indexPath.row];
        
        cell.imageView.image = [UIImage imageNamed:[[PMAccountManager sharedManager] iconNameByProvider:account.provider]];
        cell.textLabel.text = account.title;
        cell.detailTextLabel.text = account.descript;
    }
    else if([cellIdentifier isEqualToString:@"salesforceCell"])
    {
        ((PMSettingsSwitchTVCell*)cell).delegate = self;
        ((PMSettingsSwitchTVCell*)cell).switchControl.on = [[PMSettingsManager instance] getEnabledSalesforce];
    }
    else if([cellIdentifier isEqualToString:@"mailDefaultCell"])
    {
        NSString *email = [[PMSettingsManager instance] getDefaultEmail];
        cell.detailTextLabel.text = email;
    }
    else if([cellIdentifier isEqualToString:@"calendarDefaultCell"])
    {
        DBCalendar *calendar = [[PMSettingsManager instance] getDefaultCalendar];
        cell.detailTextLabel.text = calendar.name;
    }
    else if([cellIdentifier isEqualToString:@"weekStartCell"])
    {
        NSString *weekStart = [[PMSettingsManager instance] getWeekStart];
        cell.detailTextLabel.text = weekStart;
    }
    else if([cellIdentifier isEqualToString:@"openLinksWithCell"])
    {
        NSString *browserName = [[PMSettingsManager instance] getBrowserName];
        cell.detailTextLabel.text = browserName;
    }
    else if([cellIdentifier isEqualToString:@"importantCell"])
    {
        ((PMSettingsSwitchTVCell*)cell).delegate = self;
        ((PMSettingsSwitchTVCell*)cell).switchControl.on = [[PMSettingsManager instance] getEnabledImportant];
    }
    else if([cellIdentifier isEqualToString:@"organizeMailByThreadCell"])
    {
        ((PMSettingsSwitchTVCell*)cell).delegate = self;
        ((PMSettingsSwitchTVCell*)cell).switchControl.on = [[PMSettingsManager instance] getOrganizeMailByThread];
    }
    else if([cellIdentifier isEqualToString:@"signatureCell"])
    {
        BOOL perAccount = [[PMSettingsManager instance] getPerAccountSignature];
        cell.detailTextLabel.text = perAccount?@"Per Account":[[PMSettingsManager instance] getGeneralSignature];
    }
    else if([cellIdentifier isEqualToString:@"swipeOptionsCell"])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", SWIPE_OPTIONS[[[PMSettingsManager instance] getLeftSwipeOption]], SWIPE_OPTIONS[[[PMSettingsManager instance] getRightSwipeOption]]];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        _selectedIndex = indexPath;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            DBAccount *selectedAccount = [_accounts objectAtIndex:_selectedIndex.row];
            
            if([selectedAccount.type isEqualToString:ACCOUNT_TYPE_EMAIL])
            {
                [AlertManager showProgressBarWithTitle:nil view:self.tableView];
                [[PMAPIManager shared] deleteTokenWithEmail:selectedAccount.email completion:^(id error, BOOL success) {
                    [AlertManager hideProgressBar];
                    
                    NSString *accountId = selectedAccount.accountId;
                    
                    [DBAccount deleteAccount:selectedAccount];
                    
                    DBNamespace *selectedNamespace = [DBNamespace getNamespaceWithAccountId:accountId];
                    
                    NSString *currentAccountId = [PMAPIManager shared].namespaceId.account_id;
                    if(selectedNamespace)
                    {
                        [DBManager deleteNamespace:selectedNamespace];
                    }
                    
                    _accounts = [[DBManager instance] getAccounts];
                    
                    NSArray *namespaces = [[DBManager instance] getNamespaces];
                    if (namespaces.count > 0) {
                        [self buildAccountData];
                        [self.tableView reloadData];
                        
                        if([accountId isEqualToString:currentAccountId])
                        {
                            DBNamespace *activeNamespace = namespaces[0];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED object:activeNamespace];
                        }
                    } else {
                        [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
                        [self.tabBarController.navigationController setNavigationBarHidden:NO];
                    }
                    
                    //[[AppDelegate sharedInstance] updateUnreadCount];
                }];
            }
            else if([selectedAccount.type isEqualToString:ACCOUNT_TYPE_CLOUD])
            {
                if([selectedAccount.provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_DROPBOX])
                {
                    NSString *userId = selectedAccount.accountId;
                    [[DBSession sharedSession] unlinkUserId:userId];
                    
                    [DBAccount deleteAccount:selectedAccount];
                    [self buildAccountData];
                    [self.tableView reloadData];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROPBOX_ACCOUNT_DELETED object:nil];
                }
                else if([selectedAccount.provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_BOX])
                {
                    NSString *userId = selectedAccount.accountId;
                    
                    for(BOXUser *user in [BOXContentClient users])
                    {
                        if([userId isEqualToString:user.modelID])
                        {                            
                            BOXContentClient *clientForUser = [BOXContentClient clientForUser:user];
                            [clientForUser logOut];
                        }
                    }
                    
                    [DBAccount deleteAccount:selectedAccount];
                    [self buildAccountData];
                    [self.tableView reloadData];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BOX_ACCOUNT_DELETED object:nil];
                }
                else if([selectedAccount.provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE])
                {
                    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME];
                    
                    [DBAccount deleteAccount:selectedAccount];
                    [self buildAccountData];
                    [self.tableView reloadData];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOOGLEDRIVE_ACCOUNT_DELETED object:nil];
                }
                else if([selectedAccount.provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_ONEDRIVE])
                {
                    [AlertManager showProgressBarWithTitle:nil view:self.tableView];
                    for(ODClient *client in [ODClient loadClients])
                    {
                        if([selectedAccount.accountId isEqualToString:client.accountId])
                        {                            
                            [client signOutWithCompletion:^(NSError *signOutError){
                                [DBAccount deleteAccount:selectedAccount];
                                [self buildAccountData];
                                
                                dispatch_async(dispatch_get_main_queue(),^{
                                    [AlertManager hideProgressBar];
                                    [self.tableView reloadData];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONEDRIVE_ACCOUNT_DELETED object:nil];
                                });
                                
                            }];
                        }
                    }
                }
                else if([selectedAccount.provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_EVERNOTE])
                {
                    if ([[ENSession sharedSession] isAuthenticated]) {
                        [[ENSession sharedSession] unauthenticate];
                    }
                    [DBAccount deleteAccount:selectedAccount];
                    [self buildAccountData];
                    
                    [self.tableView reloadData];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVERNOTE_ACCOUNT_DELETED object:nil];
                }
            }

        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:actionDelete];
        [alert addAction:actionCancel];
        
        alert.popoverPresentationController.sourceView = cell;
        alert.popoverPresentationController.sourceRect = cell.bounds;
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    NSString *cellIdentifier = cell.reuseIdentifier;
    
    if([cellIdentifier isEqualToString:@"mailDefaultCell"])
    {
        PMDefaultEmailTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDefaultEmailTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"signatureCell"])
    {
        PMSetSignatureTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSetSignatureTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"calendarDefaultCell"])
    {
        PMDefaultCalendarTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDefaultCalendarTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"weekStartCell"])
    {
        PMWeekStartTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMWeekStartTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"openLinksWithCell"])
    {
        PMOpenLinksWithTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOpenLinksWithTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"swipeOptionsCell"])
    {
        PMOpenLinksWithTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSetSwipeOptionsTVC"];
        [tvc setDelegate:self];
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"mailNotificationsCell"])
    {
        PMSetNotificationsTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSetNotificationsTVC"];
        tvc.type = @"mail";
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"calendarNotificationsCell"])
    {
        PMSetNotificationsTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSetNotificationsTVC"];
        tvc.type = @"calendar";
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"tellAboutPlanckCell"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tell your friends about PlanckMail" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *actionEmail = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
            
            PMDraftModel *lDraft = [PMDraftModel new];
            
            lDraft.subject = @"Check out PlanckMail";
            
            lDraft.body = TELL_ABOUT_MESSAGE;
            
            lNewMailComposeVC.draft = lDraft;
            
            [self presentViewController:lNewMailComposeVC animated:YES completion:nil];
        }];
        UIAlertAction *actionSMS = [UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            if(![MFMessageComposeViewController canSendText]) {
                [AlertManager showErrorMessage:@"Your device doesn't support SMS!"];
                return;
            }
            
            //NSArray *recipents = @[@"12345678", @"72345524"];
            NSString *message = TELL_ABOUT_MESSAGE;
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            //[messageController setRecipients:recipents];
            [messageController setBody:message];
            
            // Present message view controller on screen
            [self presentViewController:messageController animated:YES completion:nil];
            
        }];
        UIAlertAction *actionFacebook = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                [controller setInitialText:TELL_ABOUT_MESSAGE];
                [self presentViewController:controller animated:YES completion:Nil];
            }
            
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *actionTwitter = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *tweetSheet = [SLComposeViewController
                                                       composeViewControllerForServiceType:SLServiceTypeTwitter];
                [tweetSheet setInitialText:TELL_ABOUT_MESSAGE];
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
            
            [alert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:actionEmail];
        [alert addAction:actionSMS];
        [alert addAction:actionFacebook];
        [alert addAction:actionTwitter];
        [alert addAction:actionCancel];
        
        alert.popoverPresentationController.sourceView = cell;
        alert.popoverPresentationController.sourceRect = cell.bounds;
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [AlertManager showErrorMessage:@"Failed to send SMS!"];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - LoginVC delegate

- (void)PMLoginVCDelegate:(PMLoginVC *)loginVC didSuccessLogin:(BOOL)state additionalAccount:(BOOL)additionalAccount {
    if (state && !additionalAccount) {
        UITabBarController *lMainTabBar = [STORYBOARD instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:lMainTabBar animated:YES];
    }
    
    [self buildAccountData];
    [self.tableView reloadData];
}

#pragma mark PMDefaultEmailTVCDelegate

-(void)defaultEmailTVC:(PMDefaultEmailTVC *)defaultEmailTVC didSelectEmail:(NSString *)email
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMDefaultCalendarTVCDelegate
-(void)defaultCalendarTVC:(PMDefaultCalendarTVC *)defaultCalendarTVC didSelectCalendar:(DBCalendar *)calendar
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:3];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMWeekStartTVCDelegate
-(void)weekStartTVC:(PMWeekStartTVC *)weekStartTVC didSelectWeekStart:(NSString *)weekStart
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:3];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMOpenLinksWithTVCDelegate
-(void)openLinksWithTVC:(PMWeekStartTVC *)openLinksWithTVC didSelectBrowser:(NSString *)browserName
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMSettingsSwitchTVCellDelegate

-(void)switchCell:(PMSettingsSwitchTVCell *)cell switchControllValueChanged:(BOOL)value
{
    if([cell.reuseIdentifier isEqualToString:@"salesforceCell"])
    {
        if(value)
        {
            PMSFAuthorizingVC *authVC = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFAuthorizingVC"];
            
            authVC.delegate = self;
            [self presentViewController:authVC animated:YES completion:nil];
        }
        else
        {
            [[PMSettingsManager instance] setSalesforceCredential:nil];
            [[PMSettingsManager instance] setEnabledSalesforce:NO];
            [[PMSettingsManager instance] setSalesforceUserInfo:nil];
            [[PMSettingsManager instance] setSalesforceOrganization:nil];
            [[DBManager instance] deleteSalesforceContacts];
            
            
            // Remove leads & opportunities view controller from tab bar controller
            PMTabBarController *tabBarController = [AppDelegate sharedInstance].tabBarController;
            NSMutableArray *controllers = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
                        
            [controllers removeObjectAtIndex:6];
            [controllers removeObjectAtIndex:6];
            
            [tabBarController setViewControllers:controllers animated:YES];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_DISABLED object:nil];
        }
    }
    else if([cell.reuseIdentifier isEqualToString:@"importantCell"])
    {
        [[PMSettingsManager instance] setEnabledImportant:value];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_IMPORTANT_CHANGED object:nil];
    }
    else if([cell.reuseIdentifier isEqualToString:@"organizeMailByThreadCell"])
        [[PMSettingsManager instance] setOrganizeMailByThread:value];
    
}

#pragma mark PMSetSignatureTVCDelegate

-(void)signatureTVC:(PMSetSignatureTVC *)tvc didSetSignature:(BOOL)perAccount signatureData:(NSDictionary *)signatureData
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMSetSwipeOptionsTVCDelegate
-(void)swipeOptionsTVC:(PMSetSwipeOptionsTVC *)tvc didSetSwipeOptions:(NSString *)leftOption rightOption:(NSString *)rightOption
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:2];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark PMSFAuthorizingVCDelegate

-(void)didSuccessAuthorizing:(NSDictionary *)authorizedData
{
    [[PMSettingsManager instance] setEnabledSalesforce:YES];
    [[PMSettingsManager instance] setSalesforceCredential:authorizedData];
    
    PMSettingsSwitchTVCell *salesforceCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [salesforceCell.switchControl setOn:YES];
    
    
    // Insert leads & opportunities view controller to tab bar controller
    PMTabBarController *tabBarController = [AppDelegate sharedInstance].tabBarController;
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
    
    UINavigationController *leadNC = [LEADS_STORYBOARD instantiateViewControllerWithIdentifier:@"LeadsNC"];
    [controllers insertObject:leadNC atIndex:6];
    
    UINavigationController *opportunitiesNC = [OPPORTUNITIES_STORYBOARD instantiateViewControllerWithIdentifier:@"OpportunitiesNC"];
    [controllers insertObject:opportunitiesNC atIndex:7];
    
    [tabBarController setViewControllers:controllers animated:YES];
    tabBarController.customizableViewControllers = nil;
    
    [AlertManager showProgressBarWithTitle:@"Loading salesforce user info..." view:self.view];
    [[PMAPIManager shared] getSalesforceUserInfo:^(id data, id error, BOOL success) {
        [AlertManager hideProgressBar];
        if(success)
        {
            
            NSDictionary *userInfo = @{
                                       @"user_id":data[@"user_id"],
                                       @"organization_id":data[@"organization_id"],
                                       @"username":data[@"username"],
                                       @"display_name":data[@"display_name"],
                                       @"email":data[@"email"]};
            [[PMSettingsManager instance] setSalesforceUserInfo:userInfo];
            
            [[PMAPIManager shared] getSalesforceOrganizationWithId:data[@"organization_id"] completion:^(id data, id error, BOOL success) {
                if(success)
                {
                    NSDictionary *organizationData = @{
                                                       @"Id": data[@"Id"],
                                                       @"Name": data[@"Name"],
                                                       @"DefaultLocaleSidKey": data[@"DefaultLocaleSidKey"]
                                                       };
                    [[PMSettingsManager instance] setSalesforceOrganization:organizationData];
                }
            }];
        }
    }];
    
    [[PMAPIManager shared] getSalesforceContacts:^(id data, id error, BOOL success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_DATA_CHANGED object:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_ENABLED object:nil];
}

-(void)didFailureAuthorizing
{
    [[PMSettingsManager instance] setEnabledSalesforce:NO];
    [[PMSettingsManager instance] setSalesforceCredential:nil];
    
    PMSettingsSwitchTVCell *salesforceCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [salesforceCell.switchControl setOn:NO];
}

@end
