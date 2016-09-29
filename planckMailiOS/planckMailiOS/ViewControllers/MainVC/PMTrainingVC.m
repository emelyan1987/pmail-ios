//
//  PMTrainingVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMTrainingVC.h"
#import "AppDelegate.h"

#import "CLContactLibrary.h"

@interface PMTrainingVC ()<UIScrollViewAccessibilityDelegate>
//@property (nonatomic, strong) NSOperationQueue *contactsQueue;
@end

@implementation PMTrainingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self performSelector:@selector(initScrollViewContent) withObject:nil afterDelay:.1];
    
    self.btnStart.layer.cornerRadius = 8;
    
//    self.contactsQueue = [NSOperationQueue new];
//    
//    [self.contactsQueue addOperationWithBlock:^{
//        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//            
//            [[CLContactLibrary sharedInstance] getContactArray:^(NSArray *data, NSError *error) {
//                
//            }];
//            
//        }];
//    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        [[CLContactLibrary sharedInstance] getContactArray:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)initScrollViewContent
{
    CGRect scrollViewFrame = self.scrollView.frame;
    CGRect page1Frame = self.pageView1.frame;
    CGRect page2Frame = self.pageView2.frame;
    CGRect page3Frame = self.pageView3.frame;
    CGRect page4Frame = self.pageView4.frame;
    CGRect page5Frame = self.pageView5.frame;
    
    [self.scrollView setContentSize:CGSizeMake(page1Frame.size.width+page2Frame.size.width+page3Frame.size.width+page4Frame.size.width+page5Frame.size.width, scrollViewFrame.size.height-50)];
    
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"smart_inbox" ofType:@"gif"];
    NSData *data1 = [NSData dataWithContentsOfFile:path1];
    [self.webView1 loadData:data1 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webView1.userInteractionEnabled = NO;
    self.webView1.scalesPageToFit = YES;
    self.webView1.scrollView.scrollEnabled = NO;
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"file" ofType:@"gif"];
    NSData *data2 = [NSData dataWithContentsOfFile:path2];
    [self.webView2 loadData:data2 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webView2.userInteractionEnabled = NO;
    self.webView2.scalesPageToFit = YES;
    self.webView2.scrollView.scrollEnabled = NO;
    
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"summarization" ofType:@"gif"];
    NSData *data3 = [NSData dataWithContentsOfFile:path3];
    [self.webView3 loadData:data3 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webView3.userInteractionEnabled = NO;
    self.webView3.scalesPageToFit = YES;
    self.webView3.scrollView.scrollEnabled = NO;
    
    NSString *path4 = [[NSBundle mainBundle] pathForResource:@"snooze" ofType:@"gif"];
    NSData *data4 = [NSData dataWithContentsOfFile:path4];
    [self.webView4 loadData:data4 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webView4.userInteractionEnabled = NO;
    self.webView4.scalesPageToFit = YES;
    self.webView4.scrollView.scrollEnabled = NO;
    
    NSString *path5 = [[NSBundle mainBundle] pathForResource:@"va" ofType:@"gif"];
    NSData *data5 = [NSData dataWithContentsOfFile:path5];
    [self.webView5 loadData:data5 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webView5.userInteractionEnabled = NO;
    self.webView5.scalesPageToFit = YES;
    self.webView5.scrollView.scrollEnabled = NO;
    
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        
        
        CGFloat offset = scrollView.contentOffset.x;
        
        int index = offset / self.view.frame.size.width;
        
        if (index == 4) {
            self.pageIndicator.hidden = YES;
            self.btnSkip.hidden = YES;
            self.btnStart.hidden = NO;
            
        } else{
            self.pageIndicator.hidden = NO;
            self.btnSkip.hidden = NO;
            self.btnStart.hidden = YES;
            self.pageIndicator.currentPage = index;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PMTabBarController *lMainTabBar = [segue destinationViewController];
    
    [AppDelegate sharedInstance].tabBarController = lMainTabBar;

}
@end
