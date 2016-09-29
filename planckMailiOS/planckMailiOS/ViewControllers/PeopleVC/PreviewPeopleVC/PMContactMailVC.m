//
//  PMContactMailVC.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/14/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactMailVC.h"
#import "FTWCache.h"
#import "PMTextManager.h"
#import "PMAPIManager.h"
#import "PMAttachmentCell.h"
#import "PMFilePreviewViewController.h"
#import "Config.h"
#import "NSString+Color.h"
#import "DBSavedContact.h"

@interface PMContactMailVC () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblSubject;
@property (weak, nonatomic) IBOutlet UILabel *lblWhere;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblFolder;
@property (weak, nonatomic) IBOutlet UIImageView *imgAttach;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *tblFileList;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblFileListHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWebViewHeightConstraint;

@property NSArray *files;
@property NSString *bodyHTML;


@end

@implementation PMContactMailVC

-(id)initWithMessage:(NSDictionary *)message contact:(PMContactModel *)contact
{
    self = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMContactMailVC"];
    self.message = message;
    self.contact = contact;
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _lblSubject.text = _message[@"subject"];
    _lblEmail.text = _contact.email;
    
    NSTimeInterval interval = [_message[@"date"] doubleValue];
    NSDate *online = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY 'at' hh:mm aaa"];
    _lblTime.text = [dateFormatter stringFromDate:online];
    
    
    _files = _message[@"files"];
    
    _lblFolder.text = _message[@"folder"][@"display_name"];
    _imgAttach.hidden = YES;
    if(_files.count>0) _imgAttach.hidden = NO;
    
    if([_contact.email isEqualToString:_message[@"from"][0][@"email"]])
        _lblWhere.text = @"From:";
    else if([_contact.email isEqualToString:_message[@"to"][0][@"email"]])
        _lblWhere.text = @"To:";
    
    
    
    
    [self performSelector:@selector(showDetail) withObject:nil afterDelay:.5];
    
    NSString *labelString = ([_contact.name isEqual:[NSNull null]] || _contact.name.length==0) ? _contact.email : _contact.name;
    
    NSString *labelLetters = [[PMTextManager shared] getLabelLettersFromText:labelString];
    _profileLabel.text = labelLetters;
    
    CGFloat hue = [labelString LabelColor];//( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = 1.0;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = 0.8;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    _profileView.backgroundColor = color;
    //_profileView.alpha = 0.5;
    _profileView.layer.cornerRadius = 25;
    _profileView.backgroundColor = [UIColor blueColor];
    
    _profileImageView.layer.cornerRadius = 25;
    _profileImageView.clipsToBounds = YES;
    _profileImageView.hidden = YES;
    
    DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:_contact.email];
    
    if(savedContact && savedContact.profileData)
    {
        UIImage *profileImage = [UIImage imageWithData:savedContact.profileData];
        if(profileImage)
        {
            _profileImageView.image = profileImage;
            _profileImageView.hidden = NO;
        }
    }
    
    
    [_contentWebView.scrollView setScrollEnabled:NO];
    
    
    [self setNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Mail Details";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}
-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showDetail {
    NSMutableString *bodyHTML = [NSMutableString stringWithString:self.message[@"body"]];
    NSString *messageId = self.message[@"id"];
    
    
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
    
    [[PMTextManager shared] getSummarizedTextFromHTML:bodyHTML messageId:messageId completion:^(NSString *result, BOOL success) {
        NSString *myHTML = DEFAULT_HTML_TEXT(result);
        
        [_contentWebView loadHTMLString:myHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];        
    }];
    
    
    _tblFileListHeightConstraint.constant = ATTACHMENT_ROW_HEIGHT * _files.count;
    
    
    
    
    [_tblFileList reloadData];
    
}

#pragma mark - UIWebView delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _contentWebViewHeightConstraint.constant = [[_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 21+78+_tblFileListHeightConstraint.constant+_contentWebViewHeightConstraint.constant)];
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
    
    PMFilePreviewViewController *controller = [FILES_STORYBOARD instantiateViewControllerWithIdentifier:@"PMFilePreviewViewController"];
    
    controller.file = file;
    
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
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
