//
//  PMBoxFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMBoxFileViewController.h"

@interface PMBoxFileViewController ()

@property (nonatomic, strong) BOXFileDownloadRequest *downloadRequest;
@end

@implementation PMBoxFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.btnAction setEnabled:NO];

    if ([self.itemType isEqualToString:BOXAPIItemTypeFile]) {
        
        BOXFileRequest *request = [self.client fileInfoRequestWithID:self.itemID];
        // We want to get all the fields for our file. Not setting this property to YES will result in the API returning only the default fields.
        request.requestAllFileFields = YES;
        [request performRequestWithCompletion:^(BOXFile *file, NSError *error) {
            if (error == nil) {
                self.fileitem = file;
                [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
                
                self.lblFileName.text = file.name;
                self.lblFileSize.text = [PMFileManager FileSizeAsString:[file.size longLongValue]];
            }
        }];
        
    } else if ([self.itemType isEqualToString:BOXAPIItemTypeWebLink]) {
        
        BOXBookmarkRequest *request = [self.client bookmarkInfoRequestWithID:self.itemID];
        // We want to get all the fields for our bookmark. Not setting this property to YES will result in the API returning only the default fields.
        request.requestAllBookmarkFields = YES;
        [request performRequestWithCompletion:^(BOXBookmark *bookmark, NSError *error) {
            if (error == nil) {
                self.fileitem = bookmark;
                [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
                
                
                
                self.lblFileName.text = bookmark.name;
                self.lblFileSize.text = [PMFileManager FileSizeAsString:[bookmark.size longLongValue]];
            }
        }];
        
    } else {
        BOXLog(@"Unknown file type");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_BOX_ACCOUNT_DELETED object:nil];
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
    [_downloadRequest cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadFile
{
    [AlertManager showProgressBarWithTitle:nil view:self.webView];
    
    // Setup our download path (the download can alternatively be done via a NSOutputStream using fileDownloadRequestWithFileID:toOutputStream:
    
    NSString *finalPath = [[PMFileManager DownloadDirectory:@"Box"] stringByAppendingPathComponent:((BOXFile*)self.fileitem).name];
    
    _downloadRequest = [self.client fileDownloadRequestWithID:self.itemID toLocalFilePath:finalPath];
    [_downloadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        float progress = (float)totalBytesTransferred / (float)totalBytesExpectedToTransfer;
        self.progressView.progress = progress;
    } completion:^(NSError *error) {
        [AlertManager hideProgressBar];
        self.progressView.hidden = YES;
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showPreviewFile:finalPath];
                [self.btnAction setEnabled:YES];
            });

        } else {
            NSLog(@"Box file download error: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@"File download was failed" controller:self];
        }
        
    }];
    
    //    //Alternative donwload method via a NSOutputStream
    //    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    //    BOXFileDownloadRequest *request = [client fileDownloadRequestWithFileID:self.itemID toOutputStream:outputStream];
    //    [request performRequestWithProgress:nil completion:^(NSError *error) {
    //        // your file data here
    //        NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    //    }];
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
