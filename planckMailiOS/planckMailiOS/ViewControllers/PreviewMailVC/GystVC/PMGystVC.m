//
//  PMGystVC.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/10/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMGystVC.h"
#import "PMGystCell.h"
#import "PMMailComposeVC.h"

#define CELL_IDENTIFIER @"PMGystCell"

@interface PMGystVC () <UITableViewDataSource, UITableViewDelegate, PMGystCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *labelColorArray;
@property (strong, nonatomic) NSMutableDictionary *bShowOriginalArray;
@end

@implementation PMGystVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 98.0;
    
    if(_labelColorArray==nil) _labelColorArray = [[NSMutableDictionary alloc] init];
    if(_bShowOriginalArray==nil) _bShowOriginalArray = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma UITableViewDelegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _messages.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMGystCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[PMGystCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    NSDictionary *lItem = _messages[indexPath.section];
    
    NSString *msgId = lItem[@"id"];
    
    BOOL showOriginal = NO;
    NSNumber *showOriginalObj = [_bShowOriginalArray objectForKey:msgId];
    if(showOriginalObj) showOriginal = [showOriginalObj boolValue];
    
    [cell bindModel:lItem showOriginal:showOriginal indexPath:indexPath];
    cell.delegate = self;
    
    //[self performSelector:@selector(showCellBackground:) withObject:indexPath afterDelay:.1];
    
    return cell;
}

-(void)showCellBackground:(NSIndexPath *)indexPath
{
    CGRect frame = [_tableView rectForRowAtIndexPath:indexPath];
    PMGystCell *cell = (PMGystCell*)[_tableView cellForRowAtIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
    whiteRoundedCornerView.layer.masksToBounds = NO;
    whiteRoundedCornerView.layer.cornerRadius = 3.0;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    whiteRoundedCornerView.layer.shadowOpacity = 0.5;
    [cell.contentView addSubview:whiteRoundedCornerView];
    [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma PMGystCellDelegate
-(void)btnReadOriginalPressed:(NSIndexPath *)indexPath
{
    NSDictionary *model = [_messages objectAtIndex:indexPath.section];
    
    NSString *msgId = model[@"id"];
    [_bShowOriginalArray setObject:[NSNumber numberWithBool:YES] forKey:msgId];
    
    //[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    //NSArray *indexPaths = @[indexPath];
    //[_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    //PMGystCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    //[cell bindModel:model showOriginal:YES indexPath:indexPath];
    //[_tableView beginUpdates];
    //[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    //[_tableView endUpdates];
    
    
    [_tableView reloadData];
    
}
-(void)btnReadSummaryPressed:(NSIndexPath *)indexPath
{
    NSDictionary *model = [_messages objectAtIndex:indexPath.section];
    NSString *msgId = model[@"id"];
    [_bShowOriginalArray setObject:[NSNumber numberWithBool:NO] forKey:msgId];
    
    
    //PMGystCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    //[cell bindModel:model showOriginal:NO indexPath:indexPath];
    
    //[_tableView beginUpdates];
    //[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];

    //[_tableView endUpdates];
    [_tableView reloadData];
}

-(void)btnReplyPressed:(NSIndexPath *)indexPath
{
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    
    NSDictionary *lItem = [_messages objectAtIndex:indexPath.section];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    lDraft.to = lItem[@"from"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    [self presentViewController:lNewMailComposeVC animated:YES completion:nil];
}
-(void)btnReplyAllPressed:(NSIndexPath *)indexPath
{
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    NSDictionary *lItem = [_messages objectAtIndex:indexPath.section];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    NSMutableArray *lEmailsArray = [NSMutableArray arrayWithArray:lItem[@"from"]];
    [lEmailsArray addObjectsFromArray:lItem[@"to"]];
    lDraft.to = lEmailsArray;
    lDraft.cc = lItem[@"cc"];
    lDraft.bcc = lItem[@"bcc"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    [self presentViewController:lNewMailComposeVC animated:YES completion:nil];
}
-(void)btnForwardPressed:(NSIndexPath *)indexPath
{
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    
    NSDictionary *lItem = [_messages objectAtIndex:indexPath.section];
    
    lNewMailComposeVC.messageId = lItem[@"id"];//@"";
    
    //lNewMailComposeVC.messageId = @"";
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    if ([_inboxMailModel.subject hasPrefix:@"Fwd:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Fwd: %@", _inboxMailModel.subject];
    }
    
    lDraft.replyBody = [NSString stringWithFormat:@"<div class=\"plancklab_quote\"><br><br><hr><span style='font-size:15px'>From: %@<br>To: %@<br>Subject: %@</br>Date: %@<br></span><hr><br>%@</div>", lItem[@"from"][0][@"email"], lItem[@"to"][0][@"email"], lItem[@"subject"], [NSDate dateWithTimeIntervalSince1970:[lItem[@"date"] doubleValue]], lItem[@"body"]];
    
    lNewMailComposeVC.draft = lDraft;
    
    [self presentViewController:lNewMailComposeVC animated:YES completion:nil];
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
