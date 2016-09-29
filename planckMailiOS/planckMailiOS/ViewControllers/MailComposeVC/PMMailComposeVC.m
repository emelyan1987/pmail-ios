//
//  PMMailComposeVC.m
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeVC.h"

#import "PMSelectionEmailView.h"
#import "PMMailComposeBodyTVCell.h"
#import "PMMailComposeAttachCell.h"
#import "PMAPIManager.h"
#import "MBProgressHUD.h"
#import "PMFileItem.h"
#import "PMFileManager.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>
#import "PMFilesNC.h"
#import "DBManager.h"
#import "DBContact.h"
#import "AlertManager.h"
#import "NSArray+DBContact.h"
#import "PMMailComposeEventVC.h"
#import "UIViewController+PMStoryboard.h"
#import "Config.h"
#import "PMSettingsManager.h"



#import "PMSnoozeAlertViewController.h"
#import "PMScheduleManager.h"
#import "PMNotificationManager.h"
#import "DBSavedContact.h"
#import "DBTrack.h"




@interface PMMailComposeVC () <PMSelectionEmailViewDelegate, UITableViewDelegate, UITableViewDataSource, PMMailComposeAttachCellDelegate, CLTokenInputViewDelegate, UIWebViewDelegate, PMMailComposeEventVCDelegate, PMAlertViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UIBarButtonItem *_sentBarBtn;
    __weak IBOutlet UIButton *_emailBtn;
    
    __weak IBOutlet UIView *actionView;
    __weak IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
    CGRect originActionViewFrame;
    __weak IBOutlet UIButton *btnTracking;
    
    
    NSMutableArray *toEmails;
    NSMutableArray *ccEmails;
    NSMutableArray *bccEmails;
    
    
    NSString *eventHtmlText;
    
    NSMutableDictionary *uploadStatuses;
    NSMutableDictionary *fileIds;
    
    NSArray *contacts;
    NSMutableArray *filteredContacts;
    
    CGFloat keyboardHeight;
    
    
    BOOL _notifyMe;
    ScheduleDateType _scheduledDateType;
    NSDate *_scheduledDate;
    NSInteger _autoAsk;
    
    BOOL _trackingMe;
    NSNumber *_trackId;
}
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) PMThread *inboxMailModel;
@property (nonatomic, strong) NSString *signature;

- (IBAction)closeBtnPressed:(id)sender;
- (IBAction)sentBtnPressed:(id)sender;
- (IBAction)selectMailBtnPressed:(id)sender;
- (IBAction)attachBtnPressed:(id)sender;
- (IBAction)calendarBtnPressed:(id)sender;
- (IBAction)trackingBtnPressed:(id)sender;

@end

static int nUploadingCount = 0;

@implementation PMMailComposeVC

#pragma mark - PMMailComposeVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    toEmails = [NSMutableArray new];
    ccEmails = [NSMutableArray new];
    bccEmails = [NSMutableArray new];
    
    
    
    _currentEmailAddress = [PMAPIManager shared].emailAddress;
    
    if(!_currentEmailAddress)
    {
        DBNamespace *namespace = [[DBManager instance] getNamespaces][0];
        _currentEmailAddress = namespace.email_address;
    }
    [_emailBtn setTitle:_currentEmailAddress forState:UIControlStateNormal];
    
    
    
    self.toTokenInputView.fieldName = @"To:";
    //self.toTokenInputView.placeholderText = @"Enter a name";
    self.toTokenInputView.drawBottomBorder = YES;
    //self.toTokenInputView.tintColor = [UIColor whiteColor];
    
    self.ccTokenInputView.fieldName = @"Cc:";
    //self.toTokenInputView.placeholderText = @"Enter a name";
    self.ccTokenInputView.drawBottomBorder = YES;
    //self.ccTokenInputView.tintColor = [UIColor whiteColor];
    
    self.bccTokenInputView.fieldName = @"Bcc:";
    //self.toTokenInputView.placeholderText = @"Enter a name";
    self.bccTokenInputView.drawBottomBorder = YES;
    //self.bccTokenInputView.tintColor = [UIColor whiteColor];
    
    self.attachTblHeightConstraint.constant = _files.count*44;
    
    
    uploadStatuses = [[NSMutableDictionary alloc] init];
    
    [self performSelector:@selector(uploadFiles) withObject:nil afterDelay:.1];
    
    
    contacts = [[DBManager instance] getSavedContacts];
    
    
    self.replyBodyWebView.scrollView.scrollEnabled = NO;
    
    [self setInitialData];
    [self configureBlurEffect];
    
    actionView.layer.cornerRadius = 16;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self performSelector:@selector(showActionView) withObject:nil afterDelay:0.1];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)showActionView
{
    [UIView animateWithDuration:0.4 animations:^{
        //actionViewBottomConstraint.constant = 8;
        
        CGRect superViewRect = self.view.frame;
        CGRect actionViewRect = actionView.frame;
        
        actionView.frame = CGRectMake(actionViewRect.origin.x, superViewRect.size.height-keyboardHeight-50, actionViewRect.size.width, actionViewRect.size.height);
        
        actionViewBottomConstraint.constant = superViewRect.size.height - actionView.frame.origin.y - actionView.frame.size.height;
        
    } completion:^(BOOL finished) {
        //originActionViewFrame = actionView.frame;
    }];
}


-(void)setInitialData
{
    self.subjectTextField.text = self.draft.subject;

    BOOL perAccountSignature = [[PMSettingsManager instance] getPerAccountSignature];
    
    
    NSString *signature;
    if(!perAccountSignature)
        signature = [[PMSettingsManager instance] getGeneralSignature];
    else
    {
        NSDictionary *signatures = [[PMSettingsManager instance] getSignaturesForAccount];
        NSString *myEmail = [PMAPIManager shared].namespaceId.email_address;
        
        signature = signatures[myEmail];
        
        if(!signature) signature = [[PMSettingsManager instance] getGeneralSignature];
    }
    self.signature = signature;
    signature = [signature stringByReplacingOccurrencesOfString:@"PlanckMail" withString:[NSString stringWithFormat:@"<a href=\"%@\">PlanckMail</a>", PLANCK_LINK]];

    
    NSString *bodyText;
    if(self.draft.body)
        bodyText = [NSString stringWithFormat:@"%@<br><br>%@", self.draft.body, signature];
    else
        bodyText = [NSString stringWithFormat:@"<br><br><br><br>%@", signature];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[bodyText dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, attributedString.length)];
    self.bodyTextView.attributedText = attributedString;
    //self.bodyTextView.text = bodyText;
    
    if(self.draft.replyBody && self.draft.replyBody.length)
    {
        [self.replyBodyWebView loadHTMLString:self.draft.replyBody baseURL:nil];
    }
    
    
    for(NSDictionary *item in self.draft.to)
    {
        NSString *email = item[@"email"];
        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
        
        NSString *name = ([item[@"name"] isEqual:[NSNull null]] || ((NSString*)item[@"name"]).length)==0?item[@"email"]:item[@"name"];
        if(savedContact && savedContact.name && savedContact.name.length) name = savedContact.name;
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        
        NSDictionary *context = @{@"name":name, @"email":email};
        CLToken *token = [[CLToken alloc] initWithDisplayText:name context:context type:type];
        [self.toTokenInputView addToken:token];
    }
    
    for(NSDictionary *item in self.draft.cc)
    {
        NSString *email = item[@"email"];
        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
        
        NSString *name = ([item[@"name"] isEqual:[NSNull null]] || ((NSString*)item[@"name"]).length)==0?item[@"email"]:item[@"name"];
        if(savedContact && savedContact.name && savedContact.name.length) name = savedContact.name;
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        
        NSDictionary *context = @{@"name":name, @"email":email};
        CLToken *token = [[CLToken alloc] initWithDisplayText:name context:context type:type];
        [self.ccTokenInputView addToken:token];
    }
    
    for(NSDictionary *item in self.draft.bcc)
    {
        NSString *email = item[@"email"];
        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
        
        NSString *name = ([item[@"name"] isEqual:[NSNull null]] || ((NSString*)item[@"name"]).length)==0?item[@"email"]:item[@"name"];
        if(savedContact && savedContact.name && savedContact.name.length) name = savedContact.name;
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        
        NSDictionary *context = @{@"name":name, @"email":email};
        CLToken *token = [[CLToken alloc] initWithDisplayText:name context:context type:type];
        [self.bccTokenInputView addToken:token];
    }
}

#pragma mark - Configure Blur
-(void)configureBlurEffect {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    self.blurEffectView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)uploadFiles
{
    for(int i=0; i<_files.count; i++)
    {
        NSString *filepath = _files[i];
        
        NSNumber *uploadedFlag = [uploadStatuses objectForKey:filepath];
        if(uploadedFlag==nil)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            PMMailComposeAttachCell *attachcell = [self.attachTableView cellForRowAtIndexPath:indexPath];
            
            NSURLSessionUploadTask *uploadTask = [[PMAPIManager shared] uploadFileWithAccount:[PMAPIManager shared].namespaceId filepath:filepath completion:^(NSURLResponse *response, id responseObject, NSError *error)
                                                  {
                                                      if(!error && [responseObject isKindOfClass:[NSArray class]])
                                                      {
                                                          NSDictionary *jsonResult = (NSDictionary*)responseObject[0];
                                                          
                                                          NSLog(@"File upload response: %@", jsonResult);
                                                          NSString *fileId = [jsonResult objectForKey:@"id"];
                                                          
                                                          
                                                          if(fileIds==nil) fileIds = [[NSMutableDictionary alloc] init];
                                                          [fileIds setObject:fileId forKey:filepath];
                                                          
                                                          [uploadStatuses setObject:[NSNumber numberWithBool:PMFileUploadStatusSucceeded] forKey:filepath];
                                                          attachcell.lblStatus.text = @"";
                                                      }
                                                      else
                                                      {
                                                          [uploadStatuses setObject:[NSNumber numberWithBool:PMFileUploadStatusFailed] forKey:filepath];
                                                          attachcell.lblStatus.text = @"Failed";
                                                      }
                                                      
                                                      
                                                      
                                                      nUploadingCount--;
                                                      if(nUploadingCount == 0) _sentBarBtn.enabled = YES;
                                                      
                                                      attachcell.progressView.hidden = YES;
                                                  }];
            _sentBarBtn.enabled = NO; nUploadingCount++;
            [uploadTask resume];
            
            [attachcell.progressView setProgressWithUploadProgressOfTask:uploadTask animated:YES];
        }
    }
}

-(void)didClickAttachDeleteButton:(NSString *)filepath
{
    [_files removeObject:filepath];
    [fileIds removeObjectForKey:filepath];
    
    self.attachTblHeightConstraint.constant = _files.count*44;
    
    [self.attachTableView reloadData];
}
#pragma mark - Private methods



- (NSMutableArray*)validateEmailWithString:(NSString*)emails {
    NSMutableArray *validEmails = [[NSMutableArray alloc] init];
    NSArray *emailArray = [emails componentsSeparatedByString:@" "];
    for (NSString *email in emailArray)
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailTest evaluateWithObject:email])
            [validEmails addObject:email];
    }
    return validEmails;
}

#pragma mark - IBAction selectors

- (void)closeBtnPressed:(id)sender {
    [self.view endEditing:YES];   
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete Draft" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        _inboxMailModel = nil;
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if(_draft.id && _draft.id.length && _draft.version)
            {
                NSDictionary *params = [self getSendMessageParams];
                if(params)
                {
                    NSDate *issuedTime = [NSDate date];
                    [AlertManager showStatusBarWithMessage:@"Deleting message..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
                    [[PMAPIManager shared] deleteDraft:_draft.id params:params completion:^(id data, id error, BOOL success) {
                        [AlertManager hideStatusBar:issuedTime];
                        
                        if(success)
                        {
                            [AlertManager showStatusBarWithMessage:@"Message deleted." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                            
                            if([_delegate respondsToSelector:@selector(PMMailComposeVCDelegate:didFinishWithResult:error:)])
                                [_delegate PMMailComposeVCDelegate:self didFinishWithResult:PMMailComposeResultSaved error:nil];
                        }
                        else
                        {
                            [AlertManager showStatusBarWithMessage:@"Deleting message failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
                        }
                    }];
                }
            }
        }];
    }];
    
    [alert addAction:actionDelete];
    
    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:@"Save Draft" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        NSDictionary *lSendParams = [self getSendMessageParams];
        //if (lSendParams != nil) {
            [self dismissViewControllerAnimated:YES completion:^{
                NSDate *issuedTime = [NSDate date];
                [AlertManager showStatusBarWithMessage:@"Saving message..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
                
                if(_draft.id && _draft.id.length)
                {
                    [[PMAPIManager shared] updateDraft:_draft.id params:lSendParams completion:^(id data, id error, BOOL success) {
                        [AlertManager hideStatusBar:issuedTime];
                        
                        if(success)
                        {
                            [AlertManager showStatusBarWithMessage:@"Message saved." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                            
                            if([_delegate respondsToSelector:@selector(PMMailComposeVCDelegate:didFinishWithResult:error:)])
                                [_delegate PMMailComposeVCDelegate:self didFinishWithResult:PMMailComposeResultSaved error:nil];
                        }
                        else
                        {
                            [AlertManager showStatusBarWithMessage:@"Saving message failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
                        }
                    }];
                }
                else
                {
                    [[PMAPIManager shared] createDraft:lSendParams completion:^(id data, id error, BOOL success) {
                        [AlertManager hideStatusBar:issuedTime];
                        
                        if(success)
                        {
                            [AlertManager showStatusBarWithMessage:@"Message saved." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                            
                            if([_delegate respondsToSelector:@selector(PMMailComposeVCDelegate:didFinishWithResult:error:)])
                                [_delegate PMMailComposeVCDelegate:self didFinishWithResult:PMMailComposeResultSaved error:nil];
                        }
                        else
                        {
                            [AlertManager showStatusBarWithMessage:@"Saving message failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
                        }
                    }];
                }
            }];
//        } else {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [[[UIAlertView alloc] initWithTitle:@"Invalid Recipients" message:@"One or more of the recipients you provided doesn't have a valid email address. If you continue, your message will not be sent to these recipients." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
//        }
    }];
    [alert addAction:actionSave];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:actionCancel];
    
    UIBarButtonItem *btnItemClose = (UIBarButtonItem*)sender;
    alert.popoverPresentationController.sourceView = btnItemClose.customView;
    alert.popoverPresentationController.sourceRect = btnItemClose.customView.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)getToString {
    NSMutableString *lToStr = [NSMutableString string];
    for (NSDictionary *item in _draft.to) {
        [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lToStr;
}
- (NSString *)getToStringWithInputArray {
    NSMutableString *lToStr = [NSMutableString string];
    for (NSDictionary *item in toEmails) {
        [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lToStr;
}
- (NSString *)getCcString {
    NSMutableString *lCcStr = [NSMutableString string];
    for (NSDictionary *item in _draft.cc) {
        [lCcStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lCcStr;
}
- (NSString *)getCcStringWithInputArray {
    NSMutableString *lCcStr = [NSMutableString string];
    for (NSDictionary *item in ccEmails) {
        [lCcStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lCcStr;
}

- (NSString *)getBccString {
    NSMutableString *lBccStr = [NSMutableString string];
    for (NSDictionary *item in _draft.bcc) {
        [lBccStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lBccStr;
}
- (NSString *)getBccStringWithInputArray {
    NSMutableString *lBccStr = [NSMutableString string];
    for (NSDictionary *item in bccEmails) {
        [lBccStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lBccStr;
}

- (NSDictionary *)getSendMessageParams
{
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *lEmailsTo = toEmails.count ? [self getToStringWithInputArray] : [self getToString];
    NSArray *emailToArray = [self validateEmailWithString:lEmailsTo];
    NSMutableArray *lTo = [NSMutableArray array];
    for (NSString *item in emailToArray) {
        if (![item isEqualToString:@""]) {
            [lTo addObject:@{
                             @"name": @"",
                             @"email": item
                             }];
        }
    }
    [params setObject:lTo forKey:@"to"];
    
    NSString *lEmailsCc = ccEmails.count ? [self getCcStringWithInputArray] : [self getCcString];
    NSArray *emailCcArray = [self validateEmailWithString:lEmailsCc];
    NSMutableArray *lCc = [NSMutableArray array];
    for (NSString *item in emailCcArray) {
        if (![item isEqualToString:@""]) {
            [lCc addObject:@{
                             @"name": @"",
                             @"email": item
                             }];
        }
    }
    [params setObject:lCc forKey:@"cc"];
    
    NSString *lEmailsBcc = bccEmails.count ? [self getBccStringWithInputArray] : [self getBccString];
    NSArray *emailBccArray = [self validateEmailWithString:lEmailsBcc];
    NSMutableArray *lBcc = [NSMutableArray array];
    for (NSString *item in emailBccArray) {
        if (![item isEqualToString:@""]) {
            [lBcc addObject:@{
                              @"name": @"",
                              @"email": item
                              }];
        }
    }
    [params setObject:lBcc forKey:@"bcc"];
    
    [params setObject:self.subjectTextField.text forKey:@"subject"];
    
    // Set email body
    NSString *replacedBody = [self.bodyTextView.text stringByReplacingOccurrencesOfString:self.signature withString:[NSString stringWithFormat:@"<div>%@</div>", [self.signature stringByReplacingOccurrencesOfString:@"PlanckMail" withString:[NSString stringWithFormat:@"<a href=\"%@\">PlanckMail</a>", PLANCK_LINK]]]];
    replacedBody = [replacedBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    NSString *htmlBody = [NSString stringWithFormat:@"<div>%@</div>", replacedBody];
    NSMutableString *lBody = [NSMutableString stringWithString:htmlBody];
    
    
    if(eventHtmlText&&eventHtmlText.length)
        [lBody appendString:eventHtmlText];
    
    if(self.draft.replyBody&&self.draft.replyBody.length)
    {
        // disable tracking for reply body
        NSString *replyBody = [self.draft.replyBody stringByReplacingOccurrencesOfString:@"track/read?log=true" withString:@"track/read?log=false"];
        
        replyBody = [self.draft.replyBody stringByReplacingOccurrencesOfString:@"track/link?log=true" withString:@"track/link?log=false"];
        
        [lBody appendString:replyBody];
    }
    
    [params setObject:lBody forKey:@"body"];
    
    
    // Set files
    NSArray *fileIdArray = [fileIds allValues];
    if(fileIdArray == nil) fileIdArray = [[NSMutableArray alloc] init];
    [params setObject:fileIdArray forKey:@"file_ids"];
    
    [params setObject:@[@{@"name":@"",@"email":_currentEmailAddress}] forKey:@"from"];
    
    if(_messageId && _messageId.length)
        [params setObject:_messageId forKey:@"reply_to_message_id"];
    if(_draft.id && _draft.id.length)
        [params setObject:_draft.id forKey:@"draft_id"];
    if(_draft.version)
        [params setObject:_draft.version forKey:@"version"];
    
    DLog(@"Mail Send Params:%@", params);
    return params;
}

- (void)sentBtnPressed:(id)sender
{
    NSDictionary *params = [self getSendMessageParams];
    
    NSArray *to = params[@"to"];
    if(to==nil || to.count==0)
    {
        [AlertManager showErrorMessage:@"To field invalid"];return;
    }
    
    NSMutableDictionary * lSendParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [self dismissViewControllerAnimated:YES completion:^{
        NSDate *issuedTime = [NSDate date];
        [AlertManager showStatusBarWithMessage:@"Sending message..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        if(_trackingMe && _trackId)
        {
            NSMutableString *lBody = [NSMutableString stringWithString:lSendParams[@"body"]];
            
            // Insert tracking URL
            NSString *urlForTrackingOpens = [NSString stringWithFormat:@"%@/read?log=true&track_id=%d", TRACK_SERVER_ROOT, [_trackId intValue]];
            [lBody appendFormat:@"<img src=\"%@\" style=\"visibility: hidden;\" width=\"1\" height=\"1\" border=\"0\" />", urlForTrackingOpens];
            
            // Replace PlanckMail link to tracking URL
            NSString *urlForTrackingLinks = [NSString stringWithFormat:@"%@/link?log=true&track_id=%d", TRACK_SERVER_ROOT, [_trackId intValue]];
            
            
            [lSendParams setObject:DEFAULT_HTML_TEXT([lBody stringByReplacingOccurrencesOfString:PLANCK_LINK withString:urlForTrackingLinks]) forKey:@"body"];
        }
        
        [[PMAPIManager shared] replyMessage:lSendParams completion:^(id data, id error, BOOL success) {
            [AlertManager hideStatusBar:issuedTime];
            if (success) {
                if (_notifyMe) {
                    
                    [[PMAPIManager shared] getThreadWithId:data[@"thread_id"] forAccount:[PMAPIManager shared].namespaceId.namespace_id completion:^(id data, id error, BOOL success) {
                        if(success)
                        {
                            PMThread *mail = [PMThread initWithDicationary:data ownerEmail:[PMAPIManager shared].namespaceId.email_address token:[PMAPIManager shared].namespaceId.token];
                            
                            _inboxMailModel = mail;
                            
                            
                            [self performSelector:@selector(scheduleMail:) withObject:mail afterDelay:3];
                        }
                    }];
                    
                    
                }
                
                // update track record on our Planck DB
                if(_trackingMe && _trackId)
                {
                    NSString *ownerEmail = data[@"from"][0][@"email"];
                    NSMutableString *targetEmails = [NSMutableString new];
                    
                    for(NSDictionary *item in data[@"to"])
                    {
                        if(targetEmails.length)
                            [targetEmails appendFormat:@",%@", item[@"email"]];
                        else
                            [targetEmails appendString:item[@"email"]];
                    }
                    for(NSDictionary *item in data[@"cc"])
                    {
                        if(targetEmails.length)
                            [targetEmails appendFormat:@",%@", item[@"email"]];
                        else
                            [targetEmails appendString:item[@"email"]];
                    }
                    for(NSDictionary *item in data[@"bcc"])
                    {
                        if(targetEmails.length)
                            [targetEmails appendFormat:@",%@", item[@"email"]];
                        else
                            [targetEmails appendString:item[@"email"]];
                    }
                    
                    [[PMAPIManager shared] updateEmailTrack:_trackId threadId:data[@"thread_id"] messageId:data[@"id"] subject:data[@"subject"] ownerEmail:ownerEmail targetEmails:targetEmails completion:^(id data, id error, BOOL success) {
                        if(success && data[@"data"])
                        {
                            NSManagedObjectContext *context = [[DBManager instance] workerContext];
                            [DBTrack createOrUpdateTrackWithData:data[@"data"] onContext:context];
                            [[DBManager instance] saveOnContext:context];
                            
                            [self performSelector:@selector(sendNotification:) withObject:NOTIFICATION_EMAIL_TRACKING_CHANGED afterDelay:3];
                        }
                    }];
                }
                [AlertManager showStatusBarWithMessage:@"Message sent." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                
                if([_delegate respondsToSelector:@selector(PMMailComposeVCDelegate:didFinishWithResult:error:)])
                    [_delegate PMMailComposeVCDelegate:self didFinishWithResult:PMMailComposeResultSent error:nil];
            }
            else
            {
                [AlertManager showStatusBarWithMessage:@"Sending message failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
            }
            
        }];
    }];
}

- (void)scheduleMail:(PMThread*)mail
{
    [[PMScheduleManager sharedInstance] scheduleMail:mail scheduleDateType:_scheduledDateType scheduleDate:_scheduledDate autoAsk:_autoAsk];
}

- (void)sendNotification:(NSString*)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (void)selectMailBtnPressed:(id)sender {
    PMSelectionEmailView *lNewSelectEmailView = [PMSelectionEmailView createView];
    
    NSArray *_itemsArray = [[DBManager instance] getNamespaces];
    NSMutableArray *_array = [NSMutableArray new];
    
    for (DBNamespace *item in _itemsArray) {
        [_array addObject:item.email_address];
    }
    
    [lNewSelectEmailView setEmails:_array];
    [lNewSelectEmailView setDelegate:self];
    [lNewSelectEmailView showInView:self.view];
}

- (IBAction)attachBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    PMFilesNC *controller = [FILES_STORYBOARD instantiateViewControllerWithIdentifier:@"FilesNC"];
    
    controller.isSelecting = YES;
    [self presentViewController:controller animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneSelectFile:) name:@"DoneSelectFile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canceledSelectFile:) name:@"CanceledSelectFile" object:nil];
    
}

- (IBAction)calendarBtnPressed:(id)sender
{
    [self.view endEditing:YES];

    PMMailComposeEventVC *lNewEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeEventVC"];
    UINavigationController *lNavContoller = [[UINavigationController alloc] initWithRootViewController:lNewEventVC];
    lNavContoller.navigationBarHidden = YES;
    [lNewEventVC setTitle:@"New Event"];
    [lNewEventVC setDelegate:self];
    
    PMMailEventModel *eventModel = [[PMMailEventModel alloc] init];
    eventModel.title = self.subjectTextField.text?:_draft.subject;
    
    
    
    NSMutableArray *participants = [NSMutableArray array];
    
    for (NSDictionary *item in toEmails) {
        [participants addObject:@{
                                  @"name": item[@"name"]?:@"",
                                  @"email": item[@"email"]
                                  }];
                                  
    }
    
    for (NSDictionary *item in ccEmails) {
        [participants addObject:@{
                                  @"name": item[@"name"]?:@"",
                                  @"email": item[@"email"]
                                  }];
        
    }
    
    for (NSDictionary *item in bccEmails) {
        [participants addObject:@{
                                  @"name": item[@"name"]?:@"",
                                  @"email": item[@"email"]
                                  }];
        
    }
    
    eventModel.participants = participants;
    //eventModel.duration = 30;
    lNewEventVC.eventModel = eventModel;
    [self presentViewController:lNavContoller animated:YES completion:nil];
    
}

- (IBAction)trackingBtnPressed:(id)sender {
    [self.view endEditing:YES];

    _trackingMe = !_trackingMe;
    
    [btnTracking setImage:[UIImage imageNamed:_trackingMe?@"tracking_selected":@"tracking"] forState:UIControlStateNormal];
    
    if(_trackingMe && !_trackId)
    {
        [AlertManager showProgressBarWithTitle:nil view:self.view];
        [[PMAPIManager shared] createEmailTrack:^(id data, id error, BOOL success) {
            if(success)
            {
                _trackId = data[@"track_id"];
            }
            else
            {
                [AlertManager showErrorMessage:@"We have any issue on tracking email for now. Please try again later."];
            }
            [AlertManager hideProgressBar];
        }];
    }
}
- (IBAction)notifyAction:(id)sender {
    [self.view endEditing:YES];

    
    NSDictionary *mailData = [self getSendMessageParams];
    
    NSArray *to = mailData[@"to"];
    NSString *subject = mailData[@"subject"];
    if(to==nil || to.count==0 || subject==nil || subject.length==0) {
        [AlertManager showErrorMessage:@"Add a valid recipient email address and subject line"];
        return;
    }
    
    PMThread *mailModel = [PMThread initWithDicationary:mailData ownerEmail:_currentEmailAddress token:[PMAPIManager shared].namespaceId.token];
    
    
    PMSnoozeAlertViewController *alert = [[PMSnoozeAlertViewController alloc] init];
    alert.view.backgroundColor = [UIColor clearColor];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.inboxMailModel = mailModel;
    alert.delegate = self;
    alert.isNotifyMe = YES;
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view addSubview:self.blurEffectView];
        
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.tabBarController.tabBar.hidden = YES;
    }];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(void) doneSelectFile:(NSNotification*) notification
{
    if(_files == nil) _files = [[NSMutableArray alloc] init];
    
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *filepath = [userInfo objectForKey:@"filepath"];
    
    if(filepath && ![_files containsObject:filepath])
    {
        [_files addObject:filepath];
        
        self.attachTblHeightConstraint.constant = _files.count*44;
        [self.attachTableView reloadData];
        
        [self performSelector:@selector(uploadFiles) withObject:nil afterDelay:.1];
        
    }
    
    NSArray *filepaths = [userInfo objectForKey:@"filepaths"];
    if(filepaths)
    {
        for(NSString *filepath in filepaths)
        {
            if(filepath && ![_files containsObject:filepath])
            {
                [_files addObject:filepath];
                
                self.attachTblHeightConstraint.constant = _files.count*44;
                [self.attachTableView reloadData];
                
                [self performSelector:@selector(uploadFiles) withObject:nil afterDelay:.1];
                
            }
        }
    }
    
    NSString *body = [userInfo objectForKey:@"body"];
    if(body && body.length>0)
    {
        NSString *bodyText = self.bodyTextView.text;
        bodyText = [bodyText stringByReplacingOccurrencesOfString:self.signature withString:@""];
        
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"%@\n\n%@", body, self.signature]];
        
        [self.bodyTextView setText:bodyText];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoneSelectFile" object:nil];
}

-(void) canceledSelectFile:(NSNotification*) notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CanceledSelectFile" object:nil];
}
#pragma mark - PMSelectionEmailView delegates

- (void)PMSelectionEmailViewDelegate:(PMSelectionEmailView *)view didSelectEmail:(NSString *)email {
    _currentEmailAddress = email;
    [_emailBtn setTitle:email forState:UIControlStateNormal];
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([tableView isEqual:self.attachTableView])
    {
        PMMailComposeAttachCell *cell = (PMMailComposeAttachCell*)[tableView dequeueReusableCellWithIdentifier:@"AttachCell"];
        
        NSString *filepath = _files[indexPath.row];
        NSNumber *uploadStatus = [uploadStatuses objectForKey:filepath];
        
        [cell bindModel:filepath uploadStatus:uploadStatus];
        cell.delegate = self;
        
        
        return cell;
    }
    else if([tableView isEqual:self.contactTableView])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterContactCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FilterContactCell"];
        }
        
        NSDictionary *contact = [filteredContacts objectAtIndex:indexPath.row];
        
        cell.textLabel.text = contact[@"name"];
        cell.detailTextLabel.text = contact[@"email"];
        return cell;
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.attachTableView])
        return _files.count;
    else if([tableView isEqual:self.contactTableView])
        return filteredContacts.count;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.attachTableView])
        return 44;
    else
        return 60;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if([tableView isEqual:self.contactTableView])
    {
        NSDictionary *context = [filteredContacts objectAtIndex:indexPath.row];
        
        NSString *name = context[@"name"];
        DBSavedContact *savedContact = context[@"obj"];
        
        if(savedContact && savedContact.name && savedContact.name.length) name = savedContact.name;
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        CLToken *token = [[CLToken alloc] initWithDisplayText:name context:context type:type];
        
        if (self.toTokenInputView.isEditing) {
            [self.toTokenInputView addToken:token];
        }
        else if(self.ccTokenInputView.isEditing){
            [self.ccTokenInputView addToken:token];
        }
        else if(self.bccTokenInputView.isEditing){
            [self.bccTokenInputView addToken:token];
        }
    }
}




#pragma mark - CLTokenInputViewDelegate

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text
{
    if ([text isEqualToString:@""]){
        filteredContacts = nil;
        self.contactTableView.hidden = YES;
    } else {
        NSString *keyword = [NSString stringWithFormat:@"*%@*", text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) or (emails like[cd] %@)", keyword, keyword];
        NSArray *tempContacts = [contacts filteredArrayUsingPredicate:predicate];
        
        filteredContacts = [NSMutableArray new];
        for(DBSavedContact *contact in tempContacts)
        {
            NSArray *emails = [contact getEmailArray];
            
            for(NSString *email in emails)
            {
                [filteredContacts addObject:@{@"name":[contact getTitle], @"email":email, @"obj":contact}];
            }
        }
        self.contactTableView.hidden = NO;
    }
    [self.contactTableView reloadData];
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    NSDictionary *contact = (NSDictionary*)token.context;
    
    
    if([view isEqual:self.toTokenInputView])
        [toEmails addObject:contact];
    else if([view isEqual:self.ccTokenInputView])
        [ccEmails addObject:contact];
    else if([view isEqual:self.bccTokenInputView])
        [bccEmails addObject:contact];
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    NSDictionary *contact = (NSDictionary*)token.context;
    
    
    if([view isEqual:self.toTokenInputView])
        [toEmails removeObject:contact];
    else if([view isEqual:self.ccTokenInputView])
        [ccEmails removeObject:contact];
    else if([view isEqual:self.bccTokenInputView])
        [bccEmails removeObject:contact];
}

- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    NSDictionary *context = @{@"name":@"", @"email":text};
    CLToken *token = [[CLToken alloc] initWithDisplayText:text context:context];
    
    
    return token;
    
    // TODO: Perhaps if the text is a valid phone number, or email address, create a token
    // to "accept" it.
    //return nil;
}

- (void)tokenInputViewDidEndEditing:(CLTokenInputView *)view
{
    NSLog(@"token input view did end editing: %@", view);
    //view.accessoryView = nil;
}

- (void)tokenInputViewDidBeginEditing:(CLTokenInputView *)view
{
    
    [self.scrollView removeConstraint:self.contactTblTopConstraint];
    self.contactTblTopConstraint = [NSLayoutConstraint constraintWithItem:self.contactTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.scrollView addConstraint:self.contactTblTopConstraint];
    
    self.contactTblHeightConstraint.constant = self.view.frame.size.height - keyboardHeight - self.scrollView.frame.origin.y - view.frame.origin.y - view.frame.size.height;
    [self.scrollView layoutIfNeeded];
    
    filteredContacts = nil;
    [self.contactTableView reloadData];
}

-(void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height
{
    //[self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    
    if([view isEqual:self.toTokenInputView])
        self.toTokenInputViewHeightConstraint.constant = height;
    else if([view isEqual:self.ccTokenInputView])
        self.ccTokenInputViewHeightConstraint.constant = height;
    else if([view isEqual:self.bccTokenInputView])
        self.bccTokenInputViewHeightConstraint.constant = height;
    
    
    [self.view setNeedsLayout];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    
    [self performSelector:@selector(showActionView) withObject:nil afterDelay:0.1];
    
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    keyboardHeight = 0;
    [self performSelector:@selector(showActionView) withObject:nil afterDelay:0.1];
}


#pragma UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([webView isEqual:self.replyBodyWebView])
    {
        NSInteger height = [[self.replyBodyWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
        
        self.replyBodyWebViewHeightConstraint.constant = height;
    }
    else if([webView isEqual:self.eventBodyWebView])
    {
        NSInteger height = [[self.eventBodyWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
        
        self.eventBodyWebViewHeightConstraint.constant = height;
    }
    
    [self.view setNeedsLayout];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    //textView.frame = newFrame;
    
    CGFloat height = newFrame.size.height;
    if(height>80)
    {
        self.bodyTextViewHeightConstraint.constant = height;
        [self.view setNeedsLayout];
    }
}

- (void)viewDidLayoutSubviews
{
    CGFloat contentHeight = self.toTokenInputViewHeightConstraint.constant + self.ccTokenInputViewHeightConstraint.constant+self.bccTokenInputViewHeightConstraint.constant+self.attachTblHeightConstraint.constant+self.bodyTextViewHeightConstraint.constant+self.replyBodyWebViewHeightConstraint.constant+self.eventBodyWebViewHeightConstraint.constant+keyboardHeight+100;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentHeight);
    
}

#pragma mark PMMailComposeEventVCDelegate

-(void)didDoneEditEvent:(PMMailEventModel *)eventModel
{
    NSMutableString *eventString = [NSMutableString new];
    
    [eventString appendFormat:@"<b>Meeting</b>: %@<br>", eventModel.title && eventModel.title.length?eventModel.title:@""];
    [eventString appendFormat:@"<b>Duration</b>: %@<br>", eventModel.durationText];
    [eventString appendFormat:@"<b>Location</b>: %@<br>", eventModel.location && eventModel.location.length?eventModel.location:@""];
    
    NSDate *from = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-YYYY"];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    
    NSDictionary *params = @{
                             @"email_id": [PMAPIManager shared].namespaceId.email_address,
                             @"start_date": [dateFormatter stringFromDate:from],
                             @"time_frame": @"3",
                             @"duration": @(eventModel.duration*60),
                             @"timezone": tzName
                             };
    
    for(NSDictionary *invitee in eventModel.participants)
    {
        NSString *email = invitee[@"email"];
        
        BOOL bContain = NO;
        for(NSDictionary *item in toEmails)
        {
            if([item[@"email"] isEqualToString:email])
            {
                bContain = YES; break;
            }
        }
        if(!bContain)
        {
            DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
            
            NSString *name = ([invitee[@"name"] isEqual:[NSNull null]] || ((NSString*)invitee[@"name"]).length)==0?invitee[@"email"]:invitee[@"name"];
            if(savedContact && savedContact.name && savedContact.name.length) name = savedContact.name;
            
            NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
            
            NSDictionary *context = @{@"name":name, @"email":email};
            CLToken *token = [[CLToken alloc] initWithDisplayText:name context:context type:type];
            [self.toTokenInputView addToken:token];
        }
    }
    
    [[PMAPIManager shared] getBusyTimeSlotsWithParams:params completion:^(id data, id error, BOOL success) {
        if(success)
        {
            
            NSDictionary *timeSlotsData = [self buildTimeSlotsDataWithIntervals:data[@"intervals"]];
            
            [eventString appendString:[self buildTimeSlotHTMLWithData:timeSlotsData eventModel:eventModel]];
            
            NSString *htmlString = DEFAULT_HTML_TEXT(eventString);
            [self.eventBodyWebView loadHTMLString:htmlString baseURL:nil];
            
            eventHtmlText = htmlString;
            
        }
    }];
}

/**
 
    return the dictionary that have the date string of the "E M/d" format as key and the time array as value.
 
 */
- (NSMutableDictionary*)buildTimeSlotsData
{
    NSMutableDictionary *timeSlots = [NSMutableDictionary new];
    
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger days = 0;
    while(days<3)
    {
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
        
        NSInteger weekday = components.weekday;
        if(weekday == 1 || weekday == 7)
        {
            date = [date dateByAddingTimeInterval:60*60*24];
            continue;
        }
        else
        {
            NSMutableArray *times = [NSMutableArray new];
            for(NSInteger h=0; h<9; h++)
            {
                NSDateComponents *dateComp = [[NSDateComponents alloc] init];
                [dateComp setYear:components.year];
                [dateComp setMonth:components.month];
                [dateComp setDay:components.day];
                
                NSDate *time = [[calendar dateFromComponents:dateComp] dateByAddingTimeInterval:60*60*(h+9)];
                
                if([self validTime:time])
                    [times addObject:time];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"E M/d"];
            
            NSString *dateKey = [dateFormatter stringFromDate:date];
            [timeSlots setValue:times forKey:dateKey];
            
            date = [date dateByAddingTimeInterval:60*60*24];
            
            days ++;
        }
    }
    
    return timeSlots;
}

- (NSMutableDictionary*)buildTimeSlotsDataWithIntervals:(NSArray*)intervals
{
    NSMutableDictionary *timeSlots = [NSMutableDictionary new];
    
    for(NSArray *interval in intervals)
    {
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:[interval[0] doubleValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"E M/d"];
        
        NSString *dateKey = [dateFormatter stringFromDate:time];
        
        NSMutableArray *times = [timeSlots objectForKey:dateKey];
        if(times == nil)
            times = [NSMutableArray new];
        [times addObject:time];
        [timeSlots setValue:times forKey:dateKey];
    }
    
    
    return timeSlots;
}
-(BOOL)validTime:(NSDate*)time
{
    NSInteger duration = 30;    // minutes
    NSDate *tempTime = [time dateByAddingTimeInterval:60*duration];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:time];
    
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setYear:components.year];
    [dateComp setMonth:components.month];
    [dateComp setDay:components.day];
    
    NSDate *toTime = [[calendar dateFromComponents:dateComp] dateByAddingTimeInterval:60*60*17];
    
    NSTimeInterval tempTimeInterval = [tempTime timeIntervalSince1970];
    
    if(tempTimeInterval>[toTime timeIntervalSince1970]) return NO;
    
    /*for(NSDictionary *slot in _busyTimeSlots)
    {
        NSTimeInterval from = [slot[@"from"] integerValue];
        NSTimeInterval to = [slot[@"to"] integerValue];
        
        if(tempTimeInterval>=from && tempTimeInterval<=to)
            return NO;
    }*/
    
    return YES;
    
}

- (NSString*)buildTimeSlotHTMLWithData:(NSDictionary*)data eventModel:(PMMailEventModel*)eventModel
{
    NSMutableString *html = [NSMutableString new];
    
    [html appendString:@"</br><div style=\"vertical-align:middle;line-height:2em;font-family:Arial Black; font-size:12px;color:gray;background-color:#efeef4;width:100%;height:25px;\">&nbsp;AVAILABILITY</div>"];
    [html appendString:@"<table width=\"100%\" border=\"0\">"];
    
    
    NSArray *keys = [data allKeys];
    NSArray *dates = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"E M/d"];
        
        NSDate *first = [dateFormatter dateFromString:a];
        NSDate *second = [dateFormatter dateFromString:b];
        return [first compare:second];
    }];
    
    NSInteger maxSlotsForDate = 0;
    
    [html appendString:@"<tr>"];
    
    
    for(NSInteger i=0; i<dates.count; i++)
    {
        NSString *date = dates[i];
        [html appendFormat:@"<td width=\"%f\" height=\"44px\" align=\"center\" valign=\"middle\"><b>%@</b></td>", 100.f/dates.count ,date];
        
        NSArray *times = [data objectForKey:date];
        if(maxSlotsForDate<times.count) maxSlotsForDate = times.count;
    }
    [html appendString:@"</tr>"];
    
    
    NSMutableArray *participants = [NSMutableArray new];
    for(NSDictionary *invitee in eventModel.participants)
    {
        NSString *email = invitee[@"email"];
        
        [participants addObject:email];
    }
    
    
    
    for(NSInteger i=0; i<maxSlotsForDate; i++)
    {
        [html appendString:@"<tr>"];
        for(NSInteger j=0; j<dates.count; j++)
        {
            NSString *date = dates[j];
            NSArray *times = [data objectForKey:date];
            
            if(i<times.count)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"h:mm a"];
                
                NSDate *time = times[i];
                NSString *createEventUrl = [NSString stringWithFormat:@"http://planckapi-dev.elasticbeanstalk.com/va/create_event/?participants=%@&sender=%@&starttime=%ld&endtime=%ld&location=%@&subject=%@",[participants componentsJoinedByString:@";"], _currentEmailAddress, (long)[time timeIntervalSince1970], (long)[time timeIntervalSince1970]+eventModel.duration*60, eventModel.location, eventModel.title];
                [html appendFormat:@"<td class=\"slot\" align=\"center\" valign=\"middle\"><div style=\"width:70px;\"><a href=\"%@\">%@</a></div></td>", createEventUrl, [[dateFormatter stringFromDate:times[i]] lowercaseString]];
            }
            else
            {
                [html appendString:@"<td>&nbsp;</td>"];
            }
        }
        [html appendString:@"</tr>"];
    }
    
    
    [html appendFormat:@"<tr><td colspan=\"%d\">&nbsp;</td></tr>", (int)dates.count];
    [html appendFormat:@"<tr><td align=\"left\" valign=\"middle\" colspan=\"%d\">Don't see a time that works for you?</td></tr>", (int)dates.count];
    [html appendFormat:@"<tr><td align=\"left\" valign=\"middle\" class=\"slot\" colspan=\"%d\"><div style=\"width:200px;\"><a href=\"http://planckapi-dev.elasticbeanstalk.com/va/create_event/\">&nbsp;&nbsp;&nbsp;None of these times work&nbsp;&nbsp;&nbsp;</a></div></td></tr>", (int)dates.count];
    [html appendString:@"</table>"];
    
    return html;
}



#pragma mark - PMAlertViewControllerDelegate

- (void)didScheduleWithDateType:(ScheduleDateType)dateType date:(NSDate *)date autoAsk:(NSInteger)autoAsk
{
    _notifyMe = YES;
    
    _scheduledDate = date;
    _scheduledDateType = dateType;
    _autoAsk = autoAsk;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        
        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
        
    }];
}

- (void)didCancelSchdule
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        
        self.tabBarController.tabBar.hidden = NO;
        [self.blurEffectView removeFromSuperview];
        
    }];
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
