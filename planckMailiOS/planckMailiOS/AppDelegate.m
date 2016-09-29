//
//  AppDelegate.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "AppDelegate.h"


#import "PMWatchRequestHandler.h"
#import "Config.h"
#import "AFNetworkActivityIndicatorManager.h"

#import <DropboxSDK/DropboxSDK.h>
#import <BoxContentSDK/BOXContentSDK.h>
#import <OneDriveSDK/OneDriveSDK.h>
#import "PMLocalNotification.h"
#import <evernote-cloud-sdk-ios/ENSDK.h>
#import <SalesforceSDKCore/SalesforceSDKManager.h>
#import "PMSettingsManager.h"
#import "PMActivityStatusView.h"
#import "PMAPIManager.h"
#import "DBManager.h"
#import "DBSavedContact.h"
#import "DBFolder.h"


#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import GoogleMaps;
@import WatchConnectivity;

@interface AppDelegate () <UIAlertViewDelegate, WCSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *statusViews;

@property (nonatomic, strong) WCSession *wcSession;
@property (nonatomic, strong) NSTimer *timerForWatch;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //TODO: don't remove this code
    //[[CLContactLibrary sharedInstance] createRandomAddressBook];
    
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    
            UIMutableUserNotificationAction *acceptAction = [UIMutableUserNotificationAction new];
            acceptAction.title = @"Okay";
            acceptAction.identifier = @"accept";
            acceptAction.activationMode = UIUserNotificationActivationModeForeground;
            acceptAction.authenticationRequired = NO;
    
            UIMutableUserNotificationAction *declineAction = [UIMutableUserNotificationAction new];
            declineAction.title = @"No";
            declineAction.identifier = @"decline";
            declineAction.activationMode = UIUserNotificationActivationModeForeground;
            declineAction.authenticationRequired = NO;
    
            UIMutableUserNotificationCategory *category = [UIMutableUserNotificationCategory new];
            [category setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextDefault];
            category.identifier = @"invite";
    
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
                                                                                     categories:[NSSet setWithObjects:acceptAction, declineAction, category, nil]];
    
            [application registerUserNotificationSettings: settings];
        }
    
//    // Create a mutable set to store the category definitions.
//    NSMutableSet* categories = [NSMutableSet set];
//    
//    // Define the actions for a meeting invite notification.
//    UIMutableUserNotificationAction* acceptAction = [[UIMutableUserNotificationAction alloc] init];
//    acceptAction.title = NSLocalizedString(@"Repondre", @"Repondre commentaire");
//    acceptAction.identifier = @"respond";
//    acceptAction.activationMode = UIUserNotificationActivationModeForeground; //UIUserNotificationActivationModeBackground if no need in foreground.
//    acceptAction.authenticationRequired = NO;
//    
//    // Create the category object and add it to the set.
//    UIMutableUserNotificationCategory* inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
//    [inviteCategory setActions:@[acceptAction]
//                    forContext:UIUserNotificationActionContextDefault];
//    inviteCategory.identifier = @"respond";
//    
//    [categories addObject:inviteCategory];
//    
//    // Configure other actions and categories and add them to the set...
//    
//    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:
//                                            (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)
//                                                                             categories:categories];
//    
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [self setUpCustomDesign];
    
    [PMLocalNotification setUpNotificationForApplication:application];
    [PMLocalNotification cancelNotifications];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [PMLocalNotification checkDisabledLocalNotification:^(DisabledLocalNotificationType type) {
        NSString *lStatusString = nil;
        switch (type) {
            case DisabledLocalNotificationTypeAlert: {
                lStatusString = @"Alert Styles";
                break;
            }
            case DisabledLocalNotificationTypeBadge: {
                lStatusString = @"Badge App Icon";
                break;
            }
            case DisabledLocalNotificationTypeSound: {
                lStatusString = @"Sounds";
                break;
            }
            case DisabledLocalNotificationTypeAll: {
                lStatusString = @"Badge App Icon, Sounds, Alert Styles";
                break;
            }
            default:
                break;
        }
        if (lStatusString.length != 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This app requires access to the %@ selected. Enable in Settings -> Notification Center -> Planck Mail.", lStatusString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open Settings", nil] show];
        }
    }];
    
	
	// ======================= DropBox Settings ============================
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@DROPBOX_APP_KEY
                            appSecret:@DROPBOX_APP_SECRET
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    // ======================= Box Settings =========================
    [BOXContentClient setClientID:@BOX_CLIENT_ID clientSecret:@BOX_CLIENT_SECRET redirectURIString:@BOX_REDIRECT_URI];
    
    // ======================= OneDrive Settings ====================
    [ODClient setMicrosoftAccountAppId:@ONEDRIVE_APP_ID scopes:@[@"onedrive.readwrite"] ];
    
    // ======================= GMSService Settings ======================
    [GMSServices provideAPIKey:@GMS_API_KEY];
    
    // ======================= EverNote Settings ======================
    [ENSession setSharedSessionConsumerKey:@EVERNOTE_CONSUMER_KEY
                            consumerSecret:@EVERNOTE_CONSUMER_SECRET
                              optionalHost:/*ENSessionHostSandbox*/nil];
    
    
    // ======================= Salesforce Settings ========================
//    [SalesforceSDKManager sharedManager].connectedAppId = SALESFORCE_CONSUMER_KEY;
//    [SalesforceSDKManager sharedManager].connectedAppCallbackUri = SALESFORCE_REDIRECT_URI;
//    [SalesforceSDKManager sharedManager].authScopes = @[ @"web", @"api" ];
    
    
    
    

    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    application.applicationIconBadgeNumber = 0;
    
    
    [application registerForRemoteNotifications];
    
    
    
    // Set notification for showing/hiding action status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusNotificationShow:) name:NOTIFICATION_STATUS_BAR_SHOW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusNotificationHide:) name:NOTIFICATION_STATUS_BAR_HIDE object:nil];
    
    // ================== WatchConnectivity Settings =================
    if(WCSession.isSupported && [WCSession defaultSession])
    {
        self.wcSession = [WCSession defaultSession];
        self.wcSession.delegate = self;
        [self.wcSession activateSession];
        
        [self performSelectorInBackground:@selector(sendContactsToWatch) withObject:nil];
    }
    
    // Set Fabric Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    
    [self doBackgroundProcess];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    BOOL retVal = YES;
    if (![[DBSession sharedSession] handleOpenURL:url])
        retVal = NO;
    else
    {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:nil]];
        }
    }
    if(![[ENSession sharedSession] handleOpenURL:url])
        retVal = NO;
    
    return retVal;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[PMLocalNotification cancelNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    DLog(@"Recieved Notification %@",notif);
}


-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return true;
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Fetch started");
    
    /*// Set up Local Notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = @"PlanckMail app was just refreshed.";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //localNotification.applicationIconBadgeNumber = 23;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];*/
    
    /*[[PMAPIManager shared] getInboxMailWithAccount:[PMAPIManager shared].namespaceId limit:50 offset:0 completion:nil];
    
    if([[PMSettingsManager instance] getEnabledSalesforce])
        [[PMAPIManager shared] getSalesforceContacts:nil];*/
    
    [self callPriortization];
    completionHandler(UIBackgroundFetchResultNewData);
    NSLog(@"Fetch completed");
}


#pragma mark - Private methods

- (void)setUpCustomDesign {
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:PM_TURQUOISE_COLOR];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - WCSessionDelegate

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    [[PMWatchRequestHandler sharedHandler] handleWatchKitExtensionRequest:message reply:replyHandler];
}
-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message
{
    [[PMWatchRequestHandler sharedHandler] handleWatchKitExtensionRequest:message reply:nil];
}

#pragma mark - Standard WatchKit Delegate

-(void)sessionWatchStateDidChange:(nonnull WCSession *)session
{
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
        if(session.reachable){
            NSLog(@"session.reachable");
        }
        
        if(session.paired){
            if(session.isWatchAppInstalled){
                
                if(session.watchDirectoryURL != nil){
                    
                }
            }
        }
    }
}

#pragma mark Timer Handler for Sending to Watch

- (void)sendContactsToWatch
{
    NSArray *contacts = [[DBManager instance] getSavedContactsWithType:CONTACT_TYPE_PHONE];
    
    NSMutableArray *data = [NSMutableArray new];
    for(DBSavedContact *contact in contacts)
    {
        [data addObject:@{@"id":contact.id, @"name":[contact getTitle]}];
    }
    [self.wcSession updateApplicationContext:@{@"contact_data":data} error:nil];
}

#pragma mark Custom Method
// =========================== Custom Method ==========================
+(instancetype)sharedInstance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{


    NSLog(@"didReceiveRemoteNotification %@", userInfo);
    
    if([userInfo isKindOfClass:[NSDictionary class]] && userInfo[@"aps"] && userInfo[@"aps"][@"alert"])
        [AlertManager showStatusBarWithMessage:userInfo[@"aps"][@"alert"] type:ACTIVITY_STATUS_TYPE_INFO time:nil];
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *devTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    DLog(@"Generated Device Token:%@", devTokenString);
    
    
    _deviceToken = devTokenString;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
    DLog(@"Failed to RegisterForRemoteNotification with error: %@", error);
}





#pragma mark Handler for StatusBar Notification

-(void)handlerStatusNotificationShow:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;

    NSString *statusType = userInfo[@"type"];
    
    UIColor *textColor, *backgroundColor;
    
    if(!statusType || [statusType isEqualToString:ACTIVITY_STATUS_TYPE_INFO])
    {
        textColor = UIColorFromRGB(0xFFFFFF);
        backgroundColor = TURQUOISE_COLOR;
    }
    else if([statusType isEqualToString:ACTIVITY_STATUS_TYPE_ERROR])
    {
        textColor = UIColorFromRGB(0xFF0000);
        backgroundColor = TURQUOISE_COLOR;
    }
    else if([statusType isEqualToString:ACTIVITY_STATUS_TYPE_PROGRESS])
    {
        textColor = UIColorFromRGB(0xFFFFFF);
        backgroundColor = TURQUOISE_COLOR;
    }
    
    UIView *view = userInfo[@"view"];
    //if(view==nil)
        view = self.tabBarController.view;
    PMActivityStatusView *statusView = [[PMActivityStatusView alloc] initFromView:view textColor:textColor backgroundColor:backgroundColor];
    
    NSString *message = userInfo[@"message"];
    
    NSDate *time = userInfo[@"time"];
    if(time)
    {
        [statusView showBarWithMessage:message];
        if(!self.statusViews) self.statusViews = [NSMutableDictionary new];
        [self.statusViews setObject:statusView forKey:time];
    }
    else
    {
        [statusView showBarWithMessage:message hideAfterDelay:2];
    }
}
-(void)handlerStatusNotificationHide:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSDate *time = userInfo[@"time"];
    
    PMActivityStatusView *statusView = [self.statusViews objectForKey:time];
    if(statusView)
    {
        [statusView hideBar];
        [self.statusViews removeObjectForKey:time];
    }
}


- (void)checkToken
{
    NSArray *namespaces = [[DBManager instance] getNamespaces];
    
    __block PMAPIManager *apiManager = [PMAPIManager shared];
    for(DBNamespace *namespace in namespaces)
    {
        [apiManager getTokenWithEmail:namespace.email_address completion:^(id data, id error, BOOL success) {
            if(success)
            {
                NSDictionary * lResponseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSString *token = lResponseDic[@"token"];
                if(![token isEqualToString:namespace.token])
                {
                    [apiManager deleteTokenWithEmail:namespace.email_address completion:^(id error, BOOL success) {
                       if(success)
                       {
                           [apiManager saveToken:namespace.token andEmail:namespace.email_address completion:^(id error, BOOL success) {
                               DLog(@"PlanckToken was replaced successfully!");
                           }];
                       }
                    }];
                }
            }
        }];
    }
}


- (void)updateFolders
{
    for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
    {
        NSString *accountId = namespace.account_id;
        [[PMAPIManager shared] getFoldersWithAccount:accountId comlpetion:^(id data, id error, BOOL success) {
            if(success && [data isKindOfClass:[NSArray class]]) {
                
                
            }
        }];
    }
}

- (void)callPriortization
{
    for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
    {
        [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id folder:@"read later" offset:0 limit:1 completion:^(id data, id error, BOOL success)
        {
            if(success && [data isKindOfClass:[NSArray class]])
            {
                PMThread *thread = data[0];
                NSString *lastMessageTimestamp = thread.lastMessageTimestamp;
                
                [[PMAPIManager shared] getThreadsWithAccount:namespace.account_id parameters:@{@"last_message_after":lastMessageTimestamp} path:@"/threads" completion:^(id data, id error, BOOL success)
                {
                    if(success && [data isKindOfClass:[NSArray class]])
                    {
                        for(PMThread *thread in data)
                        {
                            NSString *threadId = thread.id;
                            [[PMAPIManager shared] setTagToThread:threadId email:namespace.email_address completion:nil];
                        }
                    }
                }];
            }
        }];
    }
}
- (void)doBackgroundProcess
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        [self checkToken];
        
        [self updateFolders];
        
        [self callPriortization];
    });
}
@end
