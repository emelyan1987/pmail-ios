//
//  PMSFAuthorizingVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/20/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFAuthorizingVC.h"
#import "AlertManager.h"
#import "Config.h"
#import "PMRequest.h"

@interface PMSFAuthorizingVC() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
@implementation PMSFAuthorizingVC

-(void)viewDidLoad
{
    [_webView setDelegate:self];
    
    NSString *lUrlString = [PMRequest salesforceAuthorization];
    
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lUrlString]]];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(didFailureAuthorizing)])
        [self.delegate didFailureAuthorizing];
}

#pragma mark - UIWebView delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL lResult = YES;
    DLog(@"shouldStartLoadWithRequest - %@", request.URL.absoluteString);
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:SALESFORCE_REDIRECT_URI]) {
        
        NSString *queryString = [urlString substringFromIndex:SALESFORCE_REDIRECT_URI.length+1];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSArray *items = [queryString componentsSeparatedByCharactersInSet:set];
        
        NSMutableDictionary *authorizedData = [NSMutableDictionary new];
        for(NSString *item in items)
        {
            NSArray *pair = [item componentsSeparatedByString:@"="];
            NSString *key = [[pair firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pair lastObject] stringByRemovingPercentEncoding];
            [authorizedData setObject:value forKey:key];
        }
        
        if([self.delegate respondsToSelector:@selector(didSuccessAuthorizing:)])
            [self.delegate didSuccessAuthorizing:authorizedData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        lResult = NO;
    } else if ([urlString hasPrefix:@"about:"]) {
        //[MBProgressHUD hideHUDForView:_webView animated:YES];
        [AlertManager hideProgressBar];
    }
    return lResult;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //[MBProgressHUD showHUDAddedTo:_webView animated:YES];
    //[AlertManager showProgressBarWithTitle:nil view:_webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //[MBProgressHUD hideHUDForView:_webView animated:YES];
    //[AlertManager hideProgressBar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"didFailLoadWithError - %@", error);
}
@end
