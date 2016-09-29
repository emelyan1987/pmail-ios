//
//  PMTrackDetailVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMTrackDetailVC.h"
#import "CLTokenInputView.h"
#import "PMAPIManager.h"
#import "PMTrackDetailTVCell.h"
#import "DBSavedContact.h"
#import "Config.h"
#import "PMTrackMailVC.h"
#import "PMMailComposeVC.h"
#import "PMTextManager.h"

@interface PMTrackDetailVC () <UITableViewDataSource, UITableViewDelegate, CLTokenInputViewDelegate>
@property (weak, nonatomic) IBOutlet CLTokenInputView *tokenViewRecipients;
@property (weak, nonatomic) IBOutlet UILabel *lblSubject;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblOpens;
@property (weak, nonatomic) IBOutlet UILabel *lblClicks;
@property (weak, nonatomic) IBOutlet UILabel *lblReplies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tokenViewRecipientsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewRecipientsHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;


@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *targetPhoneNumber;
@property (nonatomic, strong) NSString *targetEmail;

@property (nonatomic, strong) NSNumber *opens;
@property (nonatomic, strong) NSNumber *links;
@property (nonatomic, strong) NSNumber *replies;


- (IBAction)actionBtnCallTap:(id)sender;
- (IBAction)actionBtnEmailTap:(id)sender;
@end

@implementation PMTrackDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBar];
    
    if(_track)
        [self loadData:_track[@"id"]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    _tokenViewRecipients.delegate = self;
    
    _lblSubject.text = _track[@"subject"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY HH:mm"];
    _lblTime.text = [dateFormatter stringFromDate:_track[@"created_time"]];
    
    _opens = _track[@"opens"];
    _links = _track[@"links"];
    _replies = _track[@"replies"];
    
    [self updateStatisticsData];
    
    NSArray *targetEmails = [_track[@"target_emails"] componentsSeparatedByString:@","];
    
    if(targetEmails.count==1) _targetEmail = targetEmails[0];
    for(NSString *email in targetEmails)
    {
        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
        
        NSString *name = savedContact?[savedContact getTitle]:email;
        
        NSDictionary *item = @{@"name":name, @"email":email};
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        CLToken *token = [[CLToken alloc] initWithDisplayText:name context:item type:type];
        [_tokenViewRecipients addToken:token];
        
        if(targetEmails.count==1 && savedContact) {
            NSArray *phoneNumbers = [savedContact getPhoneArray];
            if(phoneNumbers.count)
                _targetPhoneNumber = phoneNumbers[0][@"phone_number"];
        }
    }
    
    _btnCall.hidden = _targetPhoneNumber==nil;
    _btnEmail.hidden = _targetEmail==nil;
    
    
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
    lblTitle.text = @"Opend Events";
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
- (IBAction)btnViewEmailTap:(id)sender
{
    [[PMAPIManager shared] getMessageWithId:_track[@"message_id"] account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
        NSDictionary *msg = data;
        if(msg)
        {
            PMTrackMailVC *mailVC = [[PMTrackMailVC alloc] initWithMessage:msg];
            
            [self.navigationController pushViewController:mailVC animated:YES];
        }
    }];
    
    
}

-(void)updateStatisticsData
{
    _lblOpens.text = [NSString stringWithFormat:@"Opens %@", _opens?_opens:@"0"];
    _lblClicks.text = [NSString stringWithFormat:@"Clicks %@", _links?_links:@"0"];
    _lblReplies.text = [NSString stringWithFormat:@"Replies %@", _replies?_replies:@"0"];
    
}

-(void)handleRefresh:(id)sender
{
    [self loadData:_track[@"id"]];
    [_refreshControl endRefreshing];
}
-(void)loadData:(NSNumber*)trackId
{
    _items = [[PMAPIManager shared] getEmailTrackDetailList:trackId completion:^(id data, id error, BOOL success) {
        
        _items = [NSMutableArray arrayWithArray:data];
        
        _opens = [NSNumber numberWithInteger:0];
        _links = [NSNumber numberWithInteger:0];
        _replies = [NSNumber numberWithInteger:0];
        for(NSDictionary *detail in data)
        {
            if([detail[@"action_type"] isEqualToString:@"O"])
            {
                int val = [_opens intValue];
                val++;
                _opens = [NSNumber numberWithInt:val];
            }
            if([detail[@"action_type"] isEqualToString:@"L"])
            {
                int val = [_links intValue];
                val++;
                _links = [NSNumber numberWithInt:val];
            }
            if([detail[@"action_type"] isEqualToString:@"R"])
            {
                int val = [_replies intValue];
                val++;
                _replies = [NSNumber numberWithInt:val];
            }
        }
        [self updateStatisticsData];
        [_tableView reloadData];
    }];
    
    //[self updateStatisticsData:_items];
    [_tableView reloadData];
}
#pragma mark UITableViewDataSource, UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMTrackDetailTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackDetailCell"];
    
    NSDictionary *item = _items[indexPath.row];
    [cell bindData:item];
    
    return cell;
}

#pragma mark CLTokenInputViewDelegate

-(void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height
{
    _tokenViewRecipientsHeightConstraint.constant = height;
    _viewRecipientsHeightConstraint.constant = height + 20;
    
    [self.view setNeedsLayout];
}

- (IBAction)actionBtnCallTap:(id)sender
{
    NSString *phoneNumber = [[PMTextManager shared] getCallablePhoneNumber:_targetPhoneNumber];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionBtnEmailTap:(id)sender
{
    NSArray *to = @[@{@"name":@"", @"email":_targetEmail}];
    PMDraftModel *lDraft = [PMDraftModel new];
    lDraft.to = to;
    
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    lNewMailComposeVC.draft = lDraft;
    [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}
@end
