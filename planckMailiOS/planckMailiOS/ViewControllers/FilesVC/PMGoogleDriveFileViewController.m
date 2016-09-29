//
//  PMGoogleDriveFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMGoogleDriveFileViewController.h"
@interface PMGoogleDriveFileViewController ()

@property (nonatomic, strong) GTMHTTPFetcher *fetcher;
@end

@implementation PMGoogleDriveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblFileName.text = self.fileitem.title;
    self.lblFileSize.text = [PMFileManager FileSizeAsString:[self.fileitem.fileSize longLongValue]];
    
    [self.btnAction setEnabled:NO];

    [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_GOOGLEDRIVE_ACCOUNT_DELETED object:nil];
}

- (void)handlerForAccountDeleted:(NSNotification*)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnBackClicked:(id)sender {
    [_fetcher stopFetching];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadFile
{
    
    [AlertManager showProgressBarWithTitle:nil view:self.webView];
     _fetcher = [self.service.fetcherService fetcherWithURLString:self.fileitem.downloadUrl];
    
    //SEL receivedData = @selector(myFetcher:receivedData:);
    
    __weak PMGoogleDriveFileViewController *__self = self;
    [_fetcher setReceivedDataBlock:^(NSData *data) {
        //NSLog(@"%f%% Downloaded", (100.0 / [self.fileitem.fileSize longLongValue] * [data length]));
        float progress = (float)((float)[data length] / (float)[self.fileitem.fileSize longLongValue]);
        //NSLog(@"%f%% Downloaded", progress);
        __self.progressView.progress = progress;
        
    }];
    [_fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        [AlertManager hideProgressBar];
        self.progressView.hidden = YES;
        
        if (error == nil) {
            NSString *filepath = [[PMFileManager DownloadDirectory:@"GoogleDrive"] stringByAppendingPathComponent:self.fileitem.title];
            
            
            [data writeToFile:filepath atomically:YES];
            
            [self showPreviewFile:filepath];
            [self.btnAction setEnabled:YES];

        } else {
            NSLog(@"An error occurred: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@FILE_DOWNLOAD_FAILURE controller:self];
        }
    }];
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
