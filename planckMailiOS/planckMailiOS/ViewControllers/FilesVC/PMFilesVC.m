//
//  PMFilesVC.m
//  planckMailiOS
//
//  Created by admin on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMFilesVC.h"
#import "Config.h"

#import <DropboxSDK/DropboxSDK.h>
#import "PMDropboxFileListViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import "PMBoxFileListViewController.h"
#import "PMGoogleDriveFileListViewController.h"
#import "PMOneDriveFileListViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "PMLocalFileListViewController.h"
#import "PMFilesNC.h"
#import "DBAccount.h"
#import "DBManager.h"
#import "Config.h"
#import <evernote-cloud-sdk-ios/ENSDKAdvanced.h>
#import "AlertManager.h"
#import "PMEvernoteNoteListViewController.h"
#import "PMAlbumViewController.h"
#import "PMFileDriveCell.h"

@interface PMFilesVC () <UITableViewDelegate, UITableViewDataSource, DBRestClientDelegate> {
    __weak IBOutlet UITableView *_tableView;
    
    
    NSArray *_itemsArray;
    GTLServiceDrive *gtlService;
    DBRestClient *dbRestClient;
}
@end

@implementation PMFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsArray = @[
                    @{@"icon" : @"mobileIcon",
                      @"title" : @"Your Mobile",
                      @"provider" : @"Mobile"},
                    @{@"icon" : @"dropboxIcon",
                      @"title" : @"Your Dropbox",
                      @"provider" : ACCOUNT_PROVIDER_CLOUD_DROPBOX},
                    @{@"icon" : @"boxIcon",
                      @"title" : @"Your Box",
                      @"provider" : ACCOUNT_PROVIDER_CLOUD_BOX},
                    @{@"icon" : @"googleDriveIcon",
                      @"title" : @"Your GoogleDrive",
                      @"provider" : ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE},
                    @{@"icon" : @"oneDriveIcon",
                      @"title" : @"Your OneDrive",
                      @"provider" : ACCOUNT_PROVIDER_CLOUD_ONEDRIVE},
                    @{@"icon" : @"evernoteIcon",
                      @"title" : @"Your Evernote",
                      @"provider" : ACCOUNT_PROVIDER_CLOUD_EVERNOTE}
                    ];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.isSelecting = ((PMFilesNC*)self.navigationController).isSelecting;
    if(self.isSelecting)
    {
        UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"closeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
        [self.navigationItem setLeftBarButtonItem:btnClose animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationAccountChanged:) name:NOTIFICATION_ACCOUNT_CHANGED object:nil];
}

-(void)onClose
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CanceledSelectFile" object:nil userInfo:nil];
    }];
}
//TODO: don't remove this code
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    
//    localNotif.alertBody = @"Just fired new local notification";
//    localNotif.alertAction = @"New notification";
//    localNotif.category = @"invite";
//    
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 1;
//    // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
//    NSDictionary *infoDict = @{@"start time": [NSDate date], @"shifted on seconds": @"10"};
//    localNotif.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMFileDriveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileDriveCell"];
    
    
    NSDictionary *lData = _itemsArray[indexPath.section];
    NSString *provider = lData[@"provider"];
    
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:lData];
    DBAccount *account = [DBAccount getAccountWithProvider:provider];
    
    if(account) {
        [data setObject:account.email forKey:@"email"];
    }
    [cell bindData:data];
    
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *item = [_itemsArray objectAtIndex:indexPath.section];
    
    NSString *provider = [item objectForKey:@"provider"];
    
    if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_DROPBOX])
    {
        
        // ========================== Sign up from Dropbox ===========================
        
        NSArray *dropboxAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_DROPBOX];
        if(!dropboxAccounts || dropboxAccounts.count==0)
            [[DBSession sharedSession] unlinkAll];
        
        if (![[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
            [[DBSession sharedSession] linkFromController:self];
        }
        else
        {
            PMDropboxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_BOX])
    {
        // ========================== Sign up from Box ===========================
        
        NSArray *boxAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_BOX];
        
        if(!boxAccounts || boxAccounts.count==0)
        {
            for(BOXUser *user in [BOXContentClient users])
            {
                BOXContentClient *clientForUser = [BOXContentClient clientForUser:user];
                [clientForUser logOut];
            }
        }
        
        NSArray *users = [BOXContentClient users];
        
        
        if(users.count>0)
        {
            BOXUser *user = [users objectAtIndex:0];
            BOXContentClient *client = [BOXContentClient clientForUser:user];
            /*if (   ([client.session isKindOfClass:[BOXOAuth2Session class]] && !self.isAppUsers)
                || ([client.session isKindOfClass:[BOXAppUserSession class]] && self.isAppUsers)) {
                [users addObject:user];
            }*/
            
            PMBoxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
            controller.client = client;
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            // Create a new client for the account we want to add.
            BOXContentClient *client = [BOXContentClient clientForNewSession];
            
            [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
                if (error) {
                    if ([error.domain isEqualToString:BOXContentSDKErrorDomain] && error.code == BOXContentSDKAPIUserCancelledError) {
                        BOXLog(@"Authentication was cancelled, please try again.");
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:@"Login failed, please try again"
                                                                           delegate:nil
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"OK", nil];
                        [alertView show];
                    }
                } else {
                    BOXContentClient *tmpClient = [BOXContentClient clientForUser:user];
                    
                    PMBoxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
                    controller.client = tmpClient;
                    controller.isSelecting = self.isSelecting;
                    
                    [self.navigationController pushViewController:controller animated:YES];
                    
                    // add account to local database
                    NSString *name = user.name;
                    NSString *email = user.login;
                    NSString *description = email?[NSString stringWithFormat:@"Box - %@", email]:@"Box";
                    NSString *modelID = user.modelID;
                    
                    NSDictionary *accountData = @{@"title":name?name:@"Box", @"email":email?email:@"Box", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_BOX, @"account_id":modelID};
                    [DBAccount createOrUpdateAccountWithData:accountData];
                    //[[DBManager instance] save];
                }
            }];
        }
    }
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE])
    {
        // ========================== Sign up from GoogleDrive ===========================
        
        NSArray *googleDriveAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE];
        
        if(!googleDriveAccounts || googleDriveAccounts.count==0)
        {
            [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME];
        }
        
        
        // Initialize the Drive API service & load existing credentials from the keychain if available.
        gtlService = [[GTLServiceDrive alloc] init];
        gtlService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                              clientID:@GOOGLE_CLIENT_ID
                                                          clientSecret:@GOOGLE_CLIENT_SECRET];
        
        
        if (!gtlService.authorizer.canAuthorize) {
            // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
            SEL finishedSelector = @selector(viewController:finishedWithAuthToGoogleDrive:error:);
            GTMOAuth2ViewControllerTouch *authViewController =
            [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                       clientID:@GOOGLE_CLIENT_ID
                                                   clientSecret:@GOOGLE_CLIENT_SECRET
                                               keychainItemName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                       delegate:self
                                               finishedSelector:finishedSelector];
            
            [self.navigationController pushViewController:authViewController animated:YES];
        } else {
            PMGoogleDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileListViewController"];
            controller.service = gtlService;
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_ONEDRIVE])
    {
        NSArray *oneDriveAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_ONEDRIVE];
//        ODClient *oldClient = [ODClient loadCurrentClient];
//        if(oldClient)
//        {
//            [oldClient signOutWithCompletion:^(NSError *signOutError){
//                
//            }];
//        }
        if(!oneDriveAccounts || oneDriveAccounts.count==0)
        {
            for(ODClient *client in [ODClient loadClients])
            {
                [client signOutWithCompletion:^(NSError *signOutError){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUNT_CHANGED object:nil];
                }];
            }
            
        }
        
        
        NSDate *now = [NSDate date];
        NSDate *lastLoginTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"OneDriveLoginTime"];
        if([now timeIntervalSinceDate:lastLoginTime] > 3600)
        {
            [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
                if (!error){
                    [ODClient setCurrentClient:client];
                    
                    NSDate *now = [NSDate date];
                    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];

                    
                    //[ODClient loadClientWithAccountId:client.accountId];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        PMOneDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileListViewController"];
                        controller.client = client;
                        controller.isSelecting = self.isSelecting;
                        
                        [self.navigationController pushViewController:controller animated:YES];
                        
                        
                        // add account to local database
                        //NSDictionary *serviceFlags = client.serviceFlags;
                        NSDictionary *accountData = @{@"title":@"OneDrive", @"email":@"OneDrive", @"description":@"OneDrive", @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_ONEDRIVE, @"account_id":client.accountId};
                        [DBAccount createOrUpdateAccountWithData:accountData];
                        //[[DBManager instance] save];
                    });
                }
                else{
                    NSLog(@"OneDrive Authentication canceled!");
                    
                }
            }];
            
        }
        else
        {
            [ODClient clientWithCompletion:^(ODClient *client, NSError *error){
                if (!error){
                    [ODClient setCurrentClient:client];
                    
                    NSDate *now = [NSDate date];
                    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
                    
                    //[ODClient loadClientWithAccountId:client.accountId];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        PMOneDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileListViewController"];
                        controller.client = client;
                        controller.isSelecting = self.isSelecting;
                        
                        [self.navigationController pushViewController:controller animated:YES];
                        
                        // add account to local database
                        //NSDictionary *serviceFlags = client.serviceFlags;
                        NSDictionary *accountData = @{@"title":@"OneDrive", @"email":@"OneDrive", @"description":@"OneDrive", @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_ONEDRIVE, @"account_id":client.accountId};
                        [DBAccount createOrUpdateAccountWithData:accountData];
                        //[[DBManager instance] save];
                    });
                }
                else{
                    NSLog(@"OneDrive Authentication canceled!");
                    
                }
            }];
        }
            //}];
        //}        
        
    }
    else if([provider isEqualToString:@"Mobile"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionFile = [UIAlertAction actionWithTitle:@"From File" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            PMLocalFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileListViewController"];
            
            controller.isSelecting = self.isSelecting;
            [self.navigationController pushViewController:controller animated:YES];
        }];
        
        UIAlertAction *actionGallery = [UIAlertAction actionWithTitle:@"From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            PMAlbumViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMAlbumViewController"];
            
            controller.isSelecting = self.isSelecting;
            [self.navigationController pushViewController:controller animated:YES];
            
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:actionFile];
        [alert addAction:actionGallery];
        [alert addAction:actionCancel];
        
        alert.popoverPresentationController.sourceView = cell;
        alert.popoverPresentationController.sourceRect = cell.bounds;
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_EVERNOTE])
    {
        NSArray *evernoteAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_EVERNOTE];
        
        if(!evernoteAccounts || evernoteAccounts.count == 0)
        {
            if ([[ENSession sharedSession] isAuthenticated]) {
                [[ENSession sharedSession] unauthenticate];
            }
        }
        
        [[ENSession sharedSession] authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
            if (!authenticateError) {
                ENNoteStoreClient *noteStore = [[ENSession sharedSession] primaryNoteStore];
                ENUserStoreClient *userStore = [[ENSession sharedSession] userStore];
                
                
                [userStore getUserWithSuccess:^(EDAMUser *user) {
                    NSLog(@"%@", user);
                } failure:^(NSError *error) {
                    NSLog(@"User eerror");
                }];
                PMEvernoteNoteListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEvernoteNoteListViewController"];
                controller.isSelecting = self.isSelecting;
                
                [self.navigationController pushViewController:controller animated:YES];
                
                // add account to local database
                NSString *name = [ENSession sharedSession].userDisplayName;
                NSString *email = [ENSession sharedSession].userDisplayName;
                NSString *description = email?[NSString stringWithFormat:@"EverNote - %@", email]:@"EverNote";
                NSString *accountId = [ENSession sharedSession].userDisplayName;
                
                NSDictionary *accountData = @{@"title":name?name:@"EverNote", @"email":email?email:@"EverNote", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_EVERNOTE, @"account_id":accountId};
                [DBAccount createOrUpdateAccountWithData:accountData];
                //[[DBManager instance] save];
            } else if (authenticateError.code != ENErrorCodeCancelled) {
                [AlertManager showErrorMessage:@"Could not authenticate."];
            }
        }];
    }
    
}

-(void)dropboxLoginDone
{
    NSArray *userIds = [DBSession sharedSession].userIds;
    NSString *userId = [userIds lastObject];
    dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession] userId:userId];
    dbRestClient.delegate = self;
    [dbRestClient loadAccountInfo];
    
    PMDropboxFileListViewController *controller = (PMDropboxFileListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    
    controller.isSelecting = self.isSelecting;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPEN_DROPBOX_VIEW" object:nil];
}
-(void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info
{
    NSLog(@"%@", info);
    
    NSString *title = info.displayName;
    NSString *email = info.email;
    NSString *userId = info.userId;
    // add account to local database
    NSDictionary *accountData = @{@"title":title, @"email":email, @"description":[NSString stringWithFormat:@"Dropbox - %@", email], @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_DROPBOX, @"account_id": userId};
    [DBAccount createOrUpdateAccountWithData:accountData];
    //[[DBManager instance] save];
    
}

// ======= GoogleDrive Delegate ===========
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuthToGoogleDrive:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
        
        PMGoogleDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileListViewController"];
        controller.service = [self gtlDriveService];
        controller.isSelecting = self.isSelecting;

        
        [self.navigationController pushViewController:controller animated:YES];
        
        // add account to local database
        NSString *email = auth.userEmail;
        NSString *userId = auth.userID;
        NSString *description = [NSString stringWithFormat:@"GoogleDrive - %@", email?email:@""];
        NSDictionary *accountData = @{@"title":@"GoogleDrive", @"email":email?email:@"GoogleDrive", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE, @"account_id":userId};
        [DBAccount createOrUpdateAccountWithData:accountData];
        //[[DBManager instance] save];
    }
}
- (GTLServiceDrive *)gtlDriveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self gtlDriveService] setAuthorizer:auth];
}

- (void)handleNotificationAccountChanged:(NSNotification*)notification {
    [_tableView reloadData];
}
@end
