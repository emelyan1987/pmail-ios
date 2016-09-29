//
//  PMFilePreviewViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFilePreviewViewController.h"
#import "PMFileManager.h"
#import "PMNetworkManager.h"
#import "PMAPIManager.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>

#import <DropboxSDK/DropboxSDK.h>
#import <BoxContentSDK/BOXContentSDK.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import <evernote-cloud-sdk-ios/ENSDKAdvanced.h>

#import "PMMailComposeVC.h"
#import "Config.h"


#import "DBAccount.h"
#import "DBManager.h"

#import "AlertManager.h"

#define UPLOADING "Uploading..."

@interface PMFilePreviewViewController ()<DBRestClientDelegate, UIWebViewDelegate>
{
    DBRestClient *dropboxClient;
    BOXContentClient *boxClient;
    GTLServiceDrive *gtlService;
    ODClient *onedriveClient;

}


@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIButton *btnAttach;


@property PMNetworkManager *networkManager;

@property BOOL isDownloaded;
@property NSString *filepath;
@property NSURL *filepathUrl;
@end

@implementation PMFilePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self setTitle:self.file[@"filename"]];
    
    self.lblFileName.text = [self.file[@"filename"] isEqual:[NSNull null]] ? @"(No Title)" : self.file[@"filename"];
    self.lblFileSize.text = [PMFileManager FileSizeAsString:[self.file[@"size"] longLongValue]];
    
    self.btnAttach.enabled = NO;
    self.btnUpload.enabled = NO;
    
    [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
    //[self downloadFile];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)downloadFile
{
    [AlertManager showProgressBarWithTitle:nil view:self.webView];
    
    NSURLSessionDownloadTask *downloadTask = [[PMAPIManager shared] downloadFileWithAccount:[PMAPIManager shared].namespaceId file:self.file completion:^(NSURLResponse *responseData, NSURL *filepath, NSError *error) {
        
        [AlertManager hideProgressBar];
        self.progressView.hidden = YES;
        
        if(!error)
        {
            
            NSURLRequest *request = [NSURLRequest requestWithURL:filepath];
                
            //[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0.0, 50.0)"]];
            [_webView loadRequest:request];
            
            self.isDownloaded = YES;
            self.filepath = filepath.path;
            self.filepathUrl = filepath;
            
            self.btnAttach.enabled = YES;
            self.btnUpload.enabled = YES;
            
        }
    }];
    
    [self.progressView setProgressWithDownloadProgressOfTask:downloadTask animated:YES];
    [downloadTask resume];

}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"File open error: %@", error);
    
    NSString *extension = [[self.file[@"filename"] pathExtension] lowercaseString];
    NSString *iconFile = [PMFileManager IconFileByExt:extension];
    UIImage *image = [UIImage imageNamed:iconFile];
    
    _imageView.image = image;
    _imageView.hidden = NO;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (IBAction)btnAttachClicked:(id)sender
{
    if(!self.filepath) return;
    
    PMMailComposeVC *mailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    NSMutableArray *files = [[NSMutableArray alloc] init];
    [files addObject:self.filepath];
    mailComposeVC.files = files;
    
    [self presentViewController:mailComposeVC animated:YES completion:nil];
}
- (IBAction)btnUploadFileClicked:(id)sender
{
    if(!self.filepath) return;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Choose your cloud to save file"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDropbox = [UIAlertAction
                         actionWithTitle:@"Dropbox"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self onUploadFileToDropbox];
                         }];
    
    UIAlertAction *actionBox = [UIAlertAction
                                    actionWithTitle:@"Box"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToBox];
                                    }];
    
    UIAlertAction *actionGoogleDrive = [UIAlertAction
                                    actionWithTitle:@"GoogleDrive"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToGoogleDrive];
                                    }];
    
    UIAlertAction *actionOneDrive = [UIAlertAction
                                    actionWithTitle:@"OneDrive"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToOneDrive];
                                    }];
    
    UIAlertAction *actionEvernote = [UIAlertAction
                                     actionWithTitle:@"Evernote"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self onUploadFileToEvernote];
                                     }];
    
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:actionDropbox];
    [alert addAction:actionBox];
    [alert addAction:actionGoogleDrive];
    [alert addAction:actionOneDrive];
    [alert addAction:actionEvernote];
    [alert addAction:actionCancel];
    
    
    alert.popoverPresentationController.sourceView = self.btnUpload;
    alert.popoverPresentationController.sourceRect = self.btnUpload.bounds;

    [self presentViewController:alert animated:YES completion:nil];
    
    
}

// ================== Upload to Dropbox ================
-(void) onUploadFileToDropbox
{
    NSArray *dropboxAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_DROPBOX];
    if(!dropboxAccounts || dropboxAccounts.count==0)
        [[DBSession sharedSession] unlinkAll];
    
    if (![[DBSession sharedSession] isLinked]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        [self uploadFileToDropBox];
    }
}

-(void)dropboxLoginDone
{
    NSArray *userIds = [DBSession sharedSession].userIds;
    NSString *userId = [userIds lastObject];
    dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession] userId:userId];
    dropboxClient.delegate = self;
    [dropboxClient loadAccountInfo];
    
    [self uploadFileToDropBox];
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
-(void)uploadFileToDropBox
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.webView];
    
    if (dropboxClient == nil) {
        dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dropboxClient.delegate = self;
    }
    [dropboxClient uploadFile:self.file[@"filename"] toPath:@"/" withParentRev:@"" fromPath:self.filepath];
}
-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath
{
    [AlertManager hideProgressBar];
    [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your Dropbox successfully!" controller:self];
}
-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    [AlertManager hideProgressBar];
    NSLog(@"Dropbox file upload error: %@", error);
    [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
}

// =================== Upload to Box ========================
-(void)onUploadFileToBox
{
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
    if(users.count > 0)
    {
        BOXUser *user = [users objectAtIndex:0];
        boxClient = [BOXContentClient clientForUser:user];
        
        [self uploadFileToBox];
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
                    [AlertManager showAlertWithTitle:@"Error" message:@"Login failed, please try again." controller:self];
                }
            } else {
                
                // add account to local database
                NSString *name = user.name;
                NSString *email = user.login;
                NSString *description = email?[NSString stringWithFormat:@"Box - %@", email]:@"Box";
                NSString *modelID = user.modelID;
                
                NSDictionary *accountData = @{@"title":name?name:@"Box", @"email":email?email:@"Box", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_BOX, @"account_id":modelID};
                [DBAccount createOrUpdateAccountWithData:accountData];
                //[[DBManager instance] save];

                
                boxClient = [BOXContentClient clientForUser:user];
                
                [self uploadFileToBox];
            }
        }];
    }
}
-(void)uploadFileToBox
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.webView];
    BOXFileUploadRequest *uploadRequest = [boxClient fileUploadRequestToFolderWithID:BOXAPIFolderIDRoot fromLocalFilePath:self.filepath];
    
    // Optional: By default the name of the file on the local filesystem will be used as the name on Box. However, you can
    // set a different name for the file by configuring the request:
    uploadRequest.fileName = self.file[@"filename"];
    
    [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        // Update a progress bar, etc.
    } completion:^(BOXFile *file, NSError *error) {
        // Upload has completed. If successful, file will be non-nil; otherwise, error will be non-nil.
        
        [AlertManager hideProgressBar];
        
        if(!error)
        {
            [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your Box successfully!" controller:self];
        }
        else
        {
            NSLog(@"Box file upload error: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
        }
    }];
}

// ====================================== Upload to GoogleDrive =================================
-(void)onUploadFileToGoogleDrive
{
    NSArray *googleDriveAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE];
    
    if(!googleDriveAccounts || googleDriveAccounts.count==0)
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME];
    }
    
    gtlService = [[GTLServiceDrive alloc] init];
    gtlService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                                                  clientID:@GOOGLE_CLIENT_ID
                                                                              clientSecret:@GOOGLE_CLIENT_SECRET];
    
    
    if (!gtlService.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        UINavigationController *navController = [[UINavigationController alloc] init];
        
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 63)];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Google Drive"];
        UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnGoogleAuthCancelClicked:)];
        
        [navigationItem setRightBarButtonItem:barButtonItemCancel];
        [navigationBar setTranslucent:NO];
        [navigationBar setItems:[NSArray arrayWithObjects:navigationItem, nil]];
        
        [navController.view addSubview:navigationBar];
        
        SEL finishedSelector = @selector(viewController:finishedWithAuthToGoogleDrive:error:);
        GTMOAuth2ViewControllerTouch *authViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                                                      clientID:@GOOGLE_CLIENT_ID
                                                                                                  clientSecret:@GOOGLE_CLIENT_SECRET
                                                                                              keychainItemName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                                                                      delegate:self
                                                                                              finishedSelector:finishedSelector];
        
        
        [navController addChildViewController:authViewController];
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        [self uploadFileToGoogleDrive];
    }
}

-(void)uploadFileToGoogleDrive
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.webView];
    
    
    
    GTLDriveFile *driveFile = [GTLDriveFile object];
    driveFile.title = self.file[@"filename"];
    
    NSData *data = [NSData dataWithContentsOfFile:self.filepath];
    
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:self.file[@"content_type"]];

    
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:driveFile
                                            uploadParameters:uploadParameters];
    
    
    [gtlService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *updatedFile,
                                                              NSError *error) {
        [AlertManager hideProgressBar];
        
        if (error == nil) {
            [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your GoogleDrive successfully!" controller:self];
        } else {
            NSLog(@"GoogleDrive file upload error: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
        }
    }];
}

- (IBAction)btnGoogleAuthCancelClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
                                    finishedWithAuthToGoogleDrive:(GTMOAuth2Authentication *)auth
                                    error:(NSError *)error {
    
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
        
        
        [self uploadFileToGoogleDrive];
        
        
        // add account to local database
        NSString *email = auth.userEmail;
        NSString *userId = auth.userID;
        NSString *description = [NSString stringWithFormat:@"GoogleDrive - %@", email?email:@""];
        NSDictionary *accountData = @{@"title":@"GoogleDrive", @"email":email?email:@"GoogleDrive", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE, @"account_id":userId};
        [DBAccount createOrUpdateAccountWithData:accountData];
        //[[DBManager instance] save];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

// ====================== Upload to OneDrive =======================
-(void)onUploadFileToOneDrive
{
    //ODClient *client = [ODClient loadCurrentClient];
    NSArray *oneDriveAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_ONEDRIVE];
        
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
                onedriveClient = client;
                [ODClient setCurrentClient:client];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self uploadFileToOneDrive];
                });
                
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
                
                // add account to local database
                //NSDictionary *serviceFlags = client.serviceFlags;
                NSDictionary *accountData = @{@"title":@"OneDrive", @"email":@"OneDrive", @"description":@"OneDrive", @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_ONEDRIVE, @"account_id":client.accountId};
                [DBAccount createOrUpdateAccountWithData:accountData];
                //[[DBManager instance] save];

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
                onedriveClient = client;
                [ODClient setCurrentClient:client];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self uploadFileToOneDrive];
                });
                
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
            }
            else{
                NSLog(@"OneDrive Authentication canceled!");
                
            }
        }];
    }
}

-(void)uploadFileToOneDrive
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.webView];
    
    ODItemContentRequest *contentRequest = [[[[onedriveClient drive] items:@"root"] itemByPath:self.file[@"filename"]] contentRequest];
    [contentRequest uploadFromFile:self.filepathUrl completion:^(ODItem *item, NSError *error){
        // Returns the item that was just uploaded.
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [AlertManager hideProgressBar];
            
            if (error == nil) {
                [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your OneDrive successfully!" controller:self];
            } else {
                NSLog(@"OneDrive file upload error: %@", error);
                [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
                [ODClient setCurrentClient:nil];
                
            }
        });
        
        
    }];
}

-(void)onUploadFileToEvernote
{
    NSArray *evernoteAccounts = [[DBManager instance] getAccountsByProvider:ACCOUNT_PROVIDER_CLOUD_EVERNOTE];
    
    if(!evernoteAccounts || evernoteAccounts.count == 0)
    {
        if ([[ENSession sharedSession] isAuthenticated]) {
            [[ENSession sharedSession] unauthenticate];
        }
    }
    
    if([[ENSession sharedSession] isAuthenticated])
    {
        [self uploadFileToEvernote];
    }
    else
    {
        
        [[ENSession sharedSession] authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
            if (!authenticateError) {
                ENNoteStoreClient *noteStore = [[ENSession sharedSession] primaryNoteStore];
                ENUserStoreClient *userStore = [[ENSession sharedSession] userStore];
                
                
                [userStore getUserWithSuccess:^(EDAMUser *user) {
                    NSLog(@"%@", user);
                } failure:^(NSError *error) {
                    NSLog(@"User eerror");
                }];
                
                // add account to local database
                NSString *name = [ENSession sharedSession].userDisplayName;
                NSString *email = [ENSession sharedSession].userDisplayName;
                NSString *description = email?[NSString stringWithFormat:@"EverNote - %@", email]:@"EverNote";
                NSString *accountId = [ENSession sharedSession].userDisplayName;
                
                NSDictionary *accountData = @{@"title":name?name:@"EverNote", @"email":email?email:@"EverNote", @"description":description, @"type":ACCOUNT_TYPE_CLOUD, @"provider":ACCOUNT_PROVIDER_CLOUD_EVERNOTE, @"account_id":accountId};
                [DBAccount createOrUpdateAccountWithData:accountData];
                //[[DBManager instance] save];

                
                
                [self uploadFileToEvernote];
            } else if (authenticateError.code != ENErrorCodeCancelled) {
                [AlertManager showErrorMessage:@"Could not authenticate."];
            }
        }];
    }
}

-(void)uploadFileToEvernote
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.webView];
    
    ENNoteStoreClient *noteStore = [ENSession sharedSession].primaryNoteStore;
    
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        __block EDAMNotebook *planckNotebook = nil;
        
        for(EDAMNotebook *notebook in notebooks)
        {
            if([notebook.name isEqualToString:PLANCK_EVERNOTE_NOTEBOOK_NAME])
            {
                planckNotebook = notebook;
            }
        }
        
        if(!planckNotebook)
        {
            EDAMNotebook *notebookToCreate = [[EDAMNotebook alloc] init];
            notebookToCreate.name = PLANCK_EVERNOTE_NOTEBOOK_NAME;
            
            [noteStore createNotebook:notebookToCreate success:^(EDAMNotebook *notebook) {
                NSLog(@"Successfully created personal notebook %@", notebook);
                
                planckNotebook = notebook;
                [self uploadNote:planckNotebook];
            } failure:^(NSError *error) {
                NSLog(@"Failed to create the notebook with error %@", error);
            }];
        }
        else
        {
            [self uploadNote:planckNotebook];
        }
    } failure:^(NSError *error) {
        NSLog(@"List Notebooks Error : %@", error);
    }];
     
}

-(void)uploadNote:(EDAMNotebook*)notebook
{
    ENNotebook *planckNotebook = [[ENNotebook alloc] initWithNotebook:notebook];
    NSData *fileData = [NSData dataWithContentsOfFile:self.filepath];
    ENResource *resource = [[ENResource alloc] initWithData:fileData mimeType:self.file[@"content_type"]];
    resource.filename = self.file[@"filename"];
    ENNote *note = [[ENNote alloc] init];
    note.title = self.file[@"filename"];
    [note addResource:resource];
    
    [[ENSession sharedSession] uploadNote:note notebook:planckNotebook completion:^(ENNoteRef *noteRef, NSError *uploadNoteError) {
        [AlertManager hideProgressBar];
        
        if (noteRef) {
            [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your Evernote successfully!" controller:self];
        } else {
            NSLog(@"Evernote note upload error: %@", uploadNoteError);
            [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
        }
    }];
}
@end
