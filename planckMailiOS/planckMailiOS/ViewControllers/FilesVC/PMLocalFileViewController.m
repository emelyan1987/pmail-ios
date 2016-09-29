//
//  PMLocalFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMLocalFileViewController.h"
#import "PMFileManager.h"

@interface PMLocalFileViewController ()


@end

@implementation PMLocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self performSelector:@selector(loadFile:) withObject:self.fileitem.fullpath afterDelay:0.1];
    self.progressView.hidden = YES;
    self.lblFileName.text = self.fileitem.name;
    self.lblFileSize.text = [PMFileManager FileSizeAsString:self.fileitem.size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self showPreview];
}
- (IBAction)btnBackClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadFile:(NSString*)filepath
{
    [self showPreviewFile:filepath];
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
