//
//  PMLoginVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMLoginVC.h"
#import "PMAPIManager.h"
#import "Config.h"

#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "AppDelegate.h"
#import "PMSettingsManager.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "DBFolder.h"

@interface PMLoginVC () <UIWebViewDelegate, NJKWebViewProgressDelegate> {
    __weak IBOutlet UIWebView *_webView;
    __weak IBOutlet UINavigationBar *_navBar;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    BOOL _isAddtionalAccount;
    BOOL _isSuccessLogin;
    
}
@end

@implementation PMLoginVC

#pragma mark - PMLoginVC lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _isAddtionalAccount = NO;
        _isSuccessLogin = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = _navBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    NSString *lRedirectUrlString = [NSString stringWithFormat:@"in-%@://app/auth-response", APP_ID];
    NSString *lUrlString = [PMRequest loginWithAppId:APP_ID mail:@"" redirectUri:lRedirectUrlString];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lUrlString]]];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_navBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

#pragma mark - Additional methods

- (void)setAdditionalAccoutn:(BOOL)state {
    _isAddtionalAccount = state;
}

- (void)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebView delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL lResult = YES;
    DLog(@"shouldStartLoadWithRequest - %@", request.URL.absoluteString);
    NSString *lUrlString = request.URL.absoluteString;
    NSString *lowerUrlString = [request.URL.absoluteString lowercaseString];
    if ([lowerUrlString hasPrefix:[[NSString stringWithFormat:@"in-%@://app/auth-response?", APP_ID] lowercaseString]]) {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"=&"];
        NSArray *lItems = [lUrlString componentsSeparatedByCharactersInSet:set];
        
        NSString *token = lItems[1];
        
        PMAPIManager *apiManager = [PMAPIManager shared];
        [apiManager saveNamespaceIdFromToken:token completion:^(id data, id error, BOOL success)
        {
            if (success)
            {
                //[[AppDelegate sharedInstance] updateUnreadCount];
                
                // Register device token for push notification
                NSString *email = data[@"email_address"];
                NSString *deviceToken = [AppDelegate sharedInstance].deviceToken;
                if(deviceToken)
                {
                    [[PMAPIManager shared] setDeviceToken:deviceToken forEmail:email completion:nil];
                }
                
                // Synchronize datas related with mail account;
                
                // 1. Sync folders or labels
                NSString *unit = data[@"organization_unit"];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_webView animated:YES];
                
                hud.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
                //hud.dimBackground = YES;
                hud.backgroundColor = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:1.0];
                
               
                hud.labelText = [NSString stringWithFormat:@"Synching %@s...", unit];
                
                
                NSString *accountId = data[@"account_id"];
                
                [[PMAPIManager shared] getFoldersWithAccount:accountId comlpetion:^(id data, id error, BOOL success) {
                    hud.labelText = @"Synching threads...";
                    
                    [apiManager getThreadsWithAccount:accountId parameters:nil path:@"/threads" completion:^(id data, id error, BOOL success) {
                        hud.labelText = @"Synching messages...";
                        
                        [apiManager getMessagesWithThreadId:nil forAccount:accountId completion:^(id data, id error, BOOL success) {
                            hud.labelText = @"Synching calendars...";
                            
                            [apiManager getCalendarsWithAccount:accountId comlpetion:^(id data, id error, BOOL success) {
                                hud.labelText = @"Synching events...";
                                
                                [apiManager getEventsWithAccount:accountId eventParams:nil comlpetion:^(id data, id error, BOOL success) {
                                    [self dismiss];
                                    
                                    /*hud.labelText = @"Loading active spammers...";
                                     
                                     [apiManager getMessagesCountInFolder:@"Read Later" forAccount:accountId completion:^(id data, id error, BOOL success) {
                                     if(success)
                                     {
                                     NSInteger count = [data integerValue];
                                     
                                     if(count>0)
                                     {
                                     for(NSInteger i=0; i<count; i+=100)
                                     {
                                     [apiManager getMessagesWithParams:@{@"in":@"Read Later",@"offset":@(i),@"limit":@(100)} forAccount:accountId completion:^(id data, id error, BOOL success) {
                                     if(success)
                                     {
                                     NSArray *messages = data;
                                     for(NSDictionary *message in messages)
                                     {
                                     
                                     }
                                     
                                     if(i+100>count)
                                     {
                                     [self dismiss];
                                     }
                                     }
                                     else
                                     {
                                     [self dismiss];
                                     }
                                     }];
                                     }
                                     }
                                     else
                                     {
                                     [self dismiss];
                                     }
                                     }
                                     else
                                     {
                                     [self dismiss];
                                     }
                                     }];*/
                                }];
                            }];
                        }];
                    }];
                    
                    if(success && [data isKindOfClass:[NSArray class]]) {
                        
                        
                    }
                }];
                
            } else {
                if(data && data[@"is_duplicated"])
                {
                    [AlertManager showAlertWithTitle:@"Account already added" message:@"Duplicate Account" controller:self];
                }
                else
                {
                    [AlertManager showErrorMessage:@"Authentication failed. Please try again later"];
                }
            }
        }];
        
        lResult = NO;
    }
    return lResult;
}

- (void)dismiss
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:_webView];
    if(hud)
        [hud hide:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PMLoginVCDelegate:didSuccessLogin:additionalAccount:)]) {
        [_delegate PMLoginVCDelegate:self didSuccessLogin:YES additionalAccount:_isAddtionalAccount];
    }
}

//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:webView animated:YES];
//    hud.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:webView animated:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    DLog(@"didFailLoadWithError - %@", error);
//}



#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    //self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
