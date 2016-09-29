//
//  PMOneDriveFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMOneDriveFileViewController.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>

static void *ProgressObserverContext = &ProgressObserverContext;

@interface PMOneDriveFileViewController ()
{
    NSString *newFilePath;
}
@property (nonatomic, strong) ODURLSessionDownloadTask *downloadTask;
@property (nonatomic, weak) NSProgress *progress;
@end

@implementation PMOneDriveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblFileName.text = _fileitem.name;
    self.lblFileSize.text = [PMFileManager FileSizeAsString:_fileitem.size];
    
    
    [self.btnAction setEnabled:NO];
    [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_ONEDRIVE_ACCOUNT_DELETED object:nil];
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
    [_downloadTask cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)downloadFile
{
    [AlertManager showProgressBarWithTitle:nil view:self.webView];
    
    _downloadTask = [[[[self.client drive] items:_fileitem.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^()
        {
            [AlertManager hideProgressBar];
            self.progressView.hidden = YES;
        });
        
        
        if (!error)
        {
            newFilePath = [[PMFileManager DownloadDirectory:@"OneDrive"] stringByAppendingPathComponent:_fileitem.name];
            
            NSError *e;
            [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:&e];
            
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showPreviewFile:newFilePath];
                [self.btnAction setEnabled:YES];
            });
        }
        else
        {
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                [AlertManager showAlertWithTitle:@"Error" message:@FILE_DOWNLOAD_FAILURE controller:self];
//            });
        
        }
            
    }];
    
    [self showProgress:_downloadTask.progress];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}
- (void)showProgress:(NSProgress *)progress
{
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
    self.progress = progress;
}

- (void)hideProgress
{
    if (self.progress){
        [self.progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:ProgressObserverContext];
        self.progress = nil;
    }
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
