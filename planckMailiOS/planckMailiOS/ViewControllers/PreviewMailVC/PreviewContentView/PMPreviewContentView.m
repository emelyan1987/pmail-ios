//
//  PMPreviewContentView.m
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewContentView.h"
#import "PMAttachmentCell.h"
#import "FTWCache.h"
#import "PMAPIManager.h"
#import "PMTextManager.h"
#import "Config.h"
#import "PMMailManager.h"
#import "NSDate+DateConverter.h"


@interface PMPreviewContentView () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UIWebView *_contentWebView;
    __weak IBOutlet UITableView *fileListView;
    __weak IBOutlet UIView *viewRSVP;
    __weak IBOutlet UIView *viewRSVPBullet;
    __weak IBOutlet UILabel *lblRSVPTitle;
    __weak IBOutlet UILabel *lblRSVPTime;
    __weak IBOutlet UIButton *btnRSVP;
    
    NSMutableString *bodyHTML;
    NSString *messageId;
    
    NSInteger nCnt;
}
@property NSMutableArray *files;

@end

@implementation PMPreviewContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    [_contentWebView.scrollView setScrollEnabled:NO];
    [_contentWebView setDelegate:self];
//    _contentWebView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    // Setting round rect for RSVP button
    btnRSVP.layer.borderWidth = 1.0f;
    btnRSVP.layer.borderColor = PM_TURQUOISE_COLOR.CGColor;
    btnRSVP.layer.cornerRadius = 4.0f;
    
    // Setting circle for RSVP bullet view
    viewRSVPBullet.layer.cornerRadius = 5.0f;
    
    _viewRSVPHeightConstraint.constant = 0.0f;
    _tblFileListHeightConstraint.constant = 0.0f;
}

- (void)showDetail:(NSString *)dataDetail files:(NSArray *)files messageId:(NSString *)mid haveToSummarize:(BOOL)haveToSummarize {
    bodyHTML = [NSMutableString stringWithString:dataDetail];
    messageId = mid;
    
    // Insert my email address into tracking URL of email body if tracking URL exists in email body
    NSString *myEmailAddress = [PMAPIManager shared].namespaceId.email_address;
    
    NSString *trackUrlPiece = [NSString stringWithFormat:@"%@/read?log=true", TRACK_SERVER_ROOT];
    NSRange rangeOfTrackUrlPiece = [bodyHTML rangeOfString:trackUrlPiece];
    if(rangeOfTrackUrlPiece.location != NSNotFound)
    {
        [bodyHTML insertString:[NSString stringWithFormat:@"&reader_email=%@",myEmailAddress] atIndex:rangeOfTrackUrlPiece.location+rangeOfTrackUrlPiece.length];
    }
    
    trackUrlPiece = [NSString stringWithFormat:@"%@/link?log=true", TRACK_SERVER_ROOT];
    rangeOfTrackUrlPiece = [bodyHTML rangeOfString:trackUrlPiece];
    if(rangeOfTrackUrlPiece.location != NSNotFound)
    {
        [bodyHTML insertString:[NSString stringWithFormat:@"&reader_email=%@",myEmailAddress] atIndex:rangeOfTrackUrlPiece.location+rangeOfTrackUrlPiece.length];
    }
    
    
    NSString *html = DEFAULT_HTML_TEXT(bodyHTML);
    
    
    _contentWebView.hidden = YES; 
    
    [_contentWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];

//    if(haveToSummarize)
//        [[PMTextManager shared] getSummarizedTextFromHTML:bodyHTML messageId:messageId completion:^(NSString *result, BOOL success) {
//            if(success)
//            {
//                
//                NSString *myHTML = DEFAULT_HTML_TEXT(result);
//                
//                [_contentWebView loadHTMLString:myHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
//                [_contentWebView1 loadHTMLString:myHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
//            }
//        }];
    
        
    self.files = [NSMutableArray new];
    for(NSDictionary *file in files)
    {
        if(!file[@"content_id"])
        {
            [self.files addObject:file];
        }
        else
        {
            NSURLSessionDownloadTask *downloadTask = [[PMAPIManager shared] downloadFileWithAccount:[PMAPIManager shared].namespaceId file:file completion:^(NSURLResponse *responseData, NSURL *filepath, NSError *error) {
                
                
                if(!error)
                {
                    NSURLRequest *request = [NSURLRequest requestWithURL:filepath];
                    
                    bodyHTML = [bodyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"cid:%@",file[@"content_id"]] withString:[NSString stringWithFormat:@"file://%@",filepath.path]];
                    
                    [_contentWebView loadHTMLString:DEFAULT_HTML_TEXT(bodyHTML) baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
                    
                }
            }];
            
            [downloadTask resume];
        }
    }
    
    _tblFileListHeightConstraint.constant = ATTACHMENT_ROW_HEIGHT * self.files.count;
    
    [fileListView reloadData];
    
    
    _viewRSVPHeightConstraint.constant = 0;
    // Setting RSVP view
    
    [[PMMailManager sharedInstance] getEventInfoWithMessageId:messageId completion:^(NSDictionary *info) {
        if(info && ![info[@"status"] isEqualToString:@"yes"])
        {
            _viewRSVPHeightConstraint.constant = 40;
            
            NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[info[@"start_time"] doubleValue]];
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[info[@"end_time"] doubleValue]];
            
            NSString *rsvpTitle = @"You are tentatively available";
            NSString *rsvpTime = [NSString stringWithFormat:@"%@ (%@)",[startTime formattedDateString:@"EEE, M/d, hh:mm a"], [[PMMailManager sharedInstance] getFormattedDuration:[endTime timeIntervalSinceDate:startTime]]];
            if([info[@"is_owner"] boolValue])
            {
                viewRSVPBullet.backgroundColor = [UIColor greenColor];
                rsvpTitle = @"You are the organizer";
            }
            else
            {
                viewRSVPBullet.backgroundColor = [UIColor grayColor];
                
                NSString *status = info[@"status"];
                if([status isEqualToString:@"yes"])
                    rsvpTitle = @"You are going";
                if([status isEqualToString:@"no"])
                    rsvpTitle = @"You've declined";
                if([status isEqualToString:@"maybe"])
                    rsvpTitle = @"You are tentative";
            }
            
            lblRSVPTitle.text = rsvpTitle;
            lblRSVPTime.text = rsvpTime;
        }
    }];
    
    
}

- (NSInteger)contentHeight {
    return 1 + _viewRSVPHeightConstraint.constant + _tblFileListHeightConstraint.constant + _contentWebViewHeightConstraint.constant;
}

#pragma mark - UIWebView delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if([webView isEqual:_contentWebView])
    {
        NSInteger contentWidth = [[_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollWidth;"]] intValue];
        
        NSInteger contentHeight = [[_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
        
        CGSize viewSize = _contentWebView.bounds.size;
        
        float rw = viewSize.width / contentWidth;
        
        //CGFloat newHeight = rw * contentHeight;
        
        
        [_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setScale(%f)",rw]];
        
        NSString *newBody = [_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.innerHTML"]];
        [_contentWebView reload];
        
        NSInteger newHeight = [[_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
        
        _contentWebViewHeightConstraint.constant = newHeight*rw;
        [ _delegate didLoadContent];
        
        _contentWebView.hidden = NO;
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}




#pragma mark - UITableView delegates

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ATTACHMENT_ROW_HEIGHT;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMAttachmentCell *cell;
    // Load the top-level objects from the custom cell XIB.
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PMAttachmentCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    cell = [topLevelObjects objectAtIndex:0];
    
    NSDictionary *file = self.files[indexPath.row];
    [cell bindModel:file];
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *file = self.files[indexPath.row];
    
    [_delegate didSelectAttachment:file];
}

-(IBAction)btnRSVPPressed:(id)sender
{
    if(self.btnRSVPTapAction)
        self.btnRSVPTapAction(sender);
}
@end
