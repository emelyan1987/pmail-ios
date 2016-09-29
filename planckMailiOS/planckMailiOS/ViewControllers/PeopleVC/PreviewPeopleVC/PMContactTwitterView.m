//
//  PMContactTwitterView.m
//  planckMailiOS
//
//  Created by LionStar on 5/3/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMContactTwitterView.h"
#import "UITableView+BackgroundText.h"

@interface PMContactTwitterView()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) NSTimer *timer;

@end
@implementation PMContactTwitterView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _webView.delegate = self;
}

- (void)setProfileLink:(NSString*)link
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:link]];
    [_webView loadRequest:req];
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    _progressView.progress = 0;
    _isLoading = true;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _isLoading = false;
}
-(void)timerCallback {
    if (!_isLoading) {
        if (_progressView.progress >= 1) {
            _progressView.hidden = true;
            [_timer invalidate];
        }
        else {
            _progressView.progress += 0.1;
        }
    }
    else {
        _progressView.progress += 0.05;
        if (_progressView.progress >= 0.95) {
            _progressView.progress = 0.95;
        }
    }
}
@end
