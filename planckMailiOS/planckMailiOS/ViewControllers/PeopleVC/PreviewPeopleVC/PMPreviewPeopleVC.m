//
//  PMPreviewPeopleVC.m
//  planckMailiOS
//
//  Created by admin on 6/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewPeopleVC.h"
#import "Config.h"
#import "PMContactMailCell.h"
#import "PMContactFileCell.h"
#import "PMFileFilterCell.h"
#import "PMFilePreviewViewController.h"
#import "PMAPIManager.h"
#import "PMContactMailVC.h"
#import "AlertManager.h"
#import "PMFileManager.h"
#import "PMMailComposeVC.h"
#import "NSMutableArray+MessageDictionary.h"
#import "PMContactInfoTableView.h"
#import "PMContactMailTableView.h"
#import "PMContactFileTableView.h"
#import "PMContactEventTableView.h"
#import "PMContactLinkedInView.h"
#import "PMContactTwitterView.h"
#import "PMEventDetailsVC.h"
#import "PMCreateContactVC.h"


#import "UIView+PMViewCreator.h"
#import <MessageUI/MessageUI.h>

#import "PMTextManager.h"

#define LINE_HEIGHT 3
typedef NS_ENUM(NSInteger, SelectedTab) {
    InfoSelected = 0,
    MailsSelected,
    FilesSelected,
    EventsSelected,
    LinkedInSelected,
    TwitterSelected
};

@interface PMPreviewPeopleVC () <UIScrollViewDelegate, PMContactInfoTableViewDelegate, PMContactMailTableViewDelegate, PMContactFileTableViewDelegate, PMContactEventTableViewDelegate, MFMessageComposeViewControllerDelegate, PMCreateContactVCDelegate> {
    
    IBOutlet UILabel *lblContactName;
    IBOutlet UILabel *lblContactDescription;
    __weak IBOutlet UIButton *btnInfo;
    __weak IBOutlet UIButton *btnMails;
    __weak IBOutlet UIButton *btnFiles;
    __weak IBOutlet UIButton *btnEvents;
    __weak IBOutlet UIButton *btnLinkedIn;
    __weak IBOutlet UIButton *btnTwitter;
    
    __weak IBOutlet UIView *viewTabBar;
    __weak IBOutlet UIScrollView *contentView;
    __weak IBOutlet UIView *viewSelectedTabLine;
    
    SelectedTab currentSelectedTab;
    UIView *currentSelectedView;
    
    // TableViews
    __weak IBOutlet PMContactInfoTableView *infoTableView;
    __weak IBOutlet PMContactMailTableView *mailTableView;
    __weak IBOutlet PMContactFileTableView *fileTableView;
    __weak IBOutlet PMContactEventTableView *eventTableView;
    __weak IBOutlet PMContactLinkedInView *linkedInView;
    __weak IBOutlet PMContactTwitterView *twitterView;
    
    // data source
    NSMutableArray *_itemsArray;
    NSMutableArray *messages;
    NSMutableArray *files;
    NSMutableArray *events;
 
    NSDictionary *contactData;
}
@end

@implementation PMPreviewPeopleVC

#pragma mark - PreviewPeopleVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Contact Info"];
    
    NSString *title = [_contact getTitle];
    
    lblContactName.text = title;
    lblContactDescription.text = @"";
    
    
    // initialize data source
    _itemsArray = [NSMutableArray new];
    messages = [NSMutableArray new];
    files = [NSMutableArray new];
    events = [NSMutableArray new];
    
    
    infoTableView.delegate = self;
    mailTableView.delegate = self;
    fileTableView.delegate = self;
    eventTableView.delegate = self;
    
    [self updateWithContactData:contactData];
    
    [viewSelectedTabLine setBackgroundColor:PM_TURQUOISE_COLOR];
    
    currentSelectedTab = InfoSelected;
    
    
    [self performSelector:@selector(initContentView) withObject:nil afterDelay:.1];
    [self performSelectorInBackground:@selector(loadData) withObject:nil];
}
- (void)initContentView
{
    CGSize contentViewSize = contentView.frame.size;
    [contentView setContentSize:CGSizeMake(contentViewSize.width*6, contentViewSize.height)];
    [contentView setContentOffset:CGPointMake(0, 0) animated:NO];
    [contentView setContentInset:UIEdgeInsetsZero];
}
- (void)setContact:(DBSavedContact *)contact
{
    contactData = [contact convertToDictionary];
}

-(void)updateWithContactData:(NSDictionary*)data
{
    DLog(@"updateWithContactData: %@", data);
    
    contactData = data;
    
    NSString *title = contactData[@"name"];
    if(!title || title.length==0)
    {
        NSArray *emails = contactData[@"emails"];
        title = emails&&emails.count>0?emails[0]:nil;
    }
    [self setTitle:title];
    [infoTableView setContactData:contactData];
    
    _model = [[PMContactModel alloc] initWithData:contactData];
    [mailTableView setModel:_model];
    [fileTableView setModel:_model];
    [eventTableView setModel:_model];
    
    infoTableView.btnEditTapAction = ^(id sender) {
        PMCreateContactVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
        
        controller.data = contactData;
        controller.delegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    };
}

//- (void)setTitle:(NSString*)title
//{  
//    
//    UILabel *lblTitle = [[UILabel alloc]init];
//    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
//    lblTitle.text = title;
//    lblTitle.textColor = [UIColor whiteColor];
//    
//    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
//    
//    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
//    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
//    
//    [headerview addSubview:lblTitle];
//    
//    self.navigationItem.titleView = headerview;
//}

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)actionEdit:(id)sender {
    PMCreateContactVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
    DLog(@"ContactID=%@, ContactName=%@", _contact.id, _contact.name);
    controller.data = contactData;
    controller.delegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(BOOL)containsMessageWithId:(NSString*)messageId
{
    for(NSDictionary *item in messages)
    {
        if([messageId isEqualToString:item[@"id"]])
            return YES;
    }
    
    return NO;
}
-(void)loadData
{
    if (_model.email && _model.email.length) {
        NSDate *issuedTime = [NSDate date];
        [AlertManager showStatusBarWithMessage:@"Loading mails..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        NSArray *localMessages = [[PMAPIManager shared] getDetailWithAnyEmail:_model.email account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
            if(success)
            {
                NSArray *lResult = data;
                NSLog(@"%@", lResult);
                for(NSDictionary *item in lResult)
                {
                    if(![messages containsMessageWithId:item[@"id"]])
                    {
                        [messages addObject:item];
                    }
                    for (NSDictionary *f in item[@"files"]) {
                        NSMutableDictionary *file = [NSMutableDictionary dictionaryWithDictionary:f];
                        [file setObject:item[@"date"] forKey:@"date"];
                        
                        [files addObject:file];
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mailTableView setMessages:messages];
                    [fileTableView setFiles:files];
                });
                
            }
            
            [AlertManager hideStatusBar:issuedTime];
        }];
        
        messages = [NSMutableArray arrayWithArray:localMessages];
        for(NSDictionary *msg in messages)
        {
            for (NSDictionary *f in msg[@"files"]) {
                NSMutableDictionary *file = [NSMutableDictionary dictionaryWithDictionary:f];
                [file setObject:msg[@"date"] forKey:@"date"];
                [files addObject:file];
            }
            
            for (NSDictionary *e in msg[@"events"]) {
                [events addObject:e];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [mailTableView setMessages:messages];
            [fileTableView setFiles:files];
        });
    }
    
    if(_model.email && ![_model.email isEqual:[NSNull null]])
    {
        [[PMAPIManager shared] getLinkedInAndTwitterLink:_model.name emails:_model.emails company:_model.company completion:^(id data, id error, BOOL success) {
            if(success)
            {
                NSString *linkedin = data[@"linkedin"];
                [linkedInView setProfileLink:linkedin];
                
                NSString *twitter = data[@"twitter"];
                [twitterView setProfileLink:twitter];
            }
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnInfoPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*InfoSelected, 0.0f) animated:YES];
}
- (IBAction)btnMailsPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*MailsSelected, 0.0f) animated:YES];
}
- (IBAction)btnFilesPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*FilesSelected, 0.0f) animated:YES];
}
- (IBAction)btnEventsPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*EventsSelected, 0.0f) animated:YES];
}
- (IBAction)btnLinkedInPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*LinkedInSelected, 0.0f) animated:YES];
}
- (IBAction)btnTwitterPressed:(id)sender {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width*TwitterSelected, 0.0f) animated:YES];    
}

-(void)selectedTab:(SelectedTab)selectedTab
{
    [UIView animateWithDuration:.2f animations:^{
        CGRect lineCurrentFrame = viewSelectedTabLine.frame;
        CGRect lineNewFrame;
        
        NSInteger page = 0;
        if (selectedTab == InfoSelected)
        {
            lineNewFrame = CGRectMake(btnInfo.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 0;
        }
        else if (selectedTab == MailsSelected)
        {
            lineNewFrame = CGRectMake(btnMails.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 1;
        }
        else if (selectedTab == FilesSelected)
        {
            lineNewFrame = CGRectMake(btnFiles.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 2;
        }
        else if (selectedTab == EventsSelected)
        {
            lineNewFrame = CGRectMake(btnEvents.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 3;
        }
        else if (selectedTab == LinkedInSelected)
        {
            lineNewFrame = CGRectMake(btnLinkedIn.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 4;
        }
        else if (selectedTab == TwitterSelected)
        {
            lineNewFrame = CGRectMake(btnTwitter.frame.origin.x, viewTabBar.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
            
            page = 5;
        }
        
        [viewSelectedTabLine setFrame:lineNewFrame];
        
    }];
    
    currentSelectedTab = selectedTab;
    
    [btnInfo setTitleColor:currentSelectedTab==InfoSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [btnMails setTitleColor:currentSelectedTab==MailsSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [btnFiles setTitleColor:currentSelectedTab==FilesSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [btnEvents setTitleColor:currentSelectedTab==EventsSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [btnLinkedIn setTitleColor:currentSelectedTab==LinkedInSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [btnTwitter setTitleColor:currentSelectedTab==TwitterSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    
    [btnInfo.titleLabel setFont:currentSelectedTab==InfoSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [btnMails.titleLabel setFont:currentSelectedTab==MailsSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [btnFiles.titleLabel setFont:currentSelectedTab==FilesSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [btnEvents.titleLabel setFont:currentSelectedTab==EventsSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [btnLinkedIn.titleLabel setFont:currentSelectedTab==LinkedInSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [btnTwitter.titleLabel setFont:currentSelectedTab==TwitterSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == contentView) {
        
        //DLog(@"ContentSize:%f,%f", contentView.contentSize.width, contentView.contentSize.height);
        CGPoint offset = scrollView.contentOffset;
        
        
        NSInteger page = offset.x / contentView.frame.size.width;
        
        [self selectedTab:page];
    }
    
    
}

#pragma PMContactInfoTableViewDelegate
-(void)composeMail:(NSDictionary *)data
{
    NSArray *to = @[data];
    PMDraftModel *lDraft = [PMDraftModel new];
    lDraft.to = to;
    
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    lNewMailComposeVC.draft = lDraft;
    [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];

}
-(void)callPhone:(NSString *)phoneNumber
{
    phoneNumber = [[PMTextManager shared] getCallablePhoneNumber:phoneNumber];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)sendSMS:(NSString *)phoneNumber
{
    if(![MFMessageComposeViewController canSendText]) {
        [AlertManager showErrorMessage:@"Your device doesn't support SMS!"];
        return;
    }
    
    phoneNumber = [[PMTextManager shared] getCallablePhoneNumber:phoneNumber];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:@[phoneNumber]];
    [messageController setBody:nil];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

#pragma MFMessageComposeViewControllerDelegate implementation
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [AlertManager showErrorMessage:@"Failed to send SMS!"];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma PMContactMailTableViewDelegate
-(void)didSelectMessage:(NSDictionary *)message
{
    PMContactMailVC *vc = [[PMContactMailVC alloc] initWithMessage:message contact:self.model];
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)didSelectAttachment:(NSDictionary *)file
{
    PMFilePreviewViewController *controller = [FILES_STORYBOARD instantiateViewControllerWithIdentifier:@"PMFilePreviewViewController"];
    
    controller.file = file;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma PMContactFileTableViewDelegate
-(void)didSelectFile:(NSDictionary *)file
{
    PMFilePreviewViewController *controller = [FILES_STORYBOARD instantiateViewControllerWithIdentifier:@"PMFilePreviewViewController"];
    
    controller.file = file;
    
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}

#pragma PMContactEventTableViewDelegate
-(void)didSelectEvent:(PMEventModel *)event index:(NSInteger)index
{
    PMEventDetailsVC *lDetailEventVC = [[PMEventDetailsVC alloc] initWithEvents:events index:index];
    
    [self.navigationController pushViewController:lDetailEventVC animated:YES];
}
-(void)didLoadEvents:(NSArray *)eventsArray
{
    events = [NSMutableArray arrayWithArray:eventsArray];
}


#pragma PMCreateContactVCDelegate implementation

-(void)didSaveContact:(DBSavedContact *)contact
{
    DLog(@"DidSaveContactWithData:%@,%@", contact.name, contact.emails);
    [self updateWithContactData:[contact convertToDictionary]];
    
    
}
@end
