//
//  PMMailComposeVC.h
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "UIViewController+PMStoryboard.h"
#import "PMDraftModel.h"

#import "CLTokenInputView.h"

typedef enum {
    PMMailComposeResultCancelled,
    PMMailComposeResultSaved,
    PMMailComposeResultSent,
    PMMailComposeResultFailed
} PMMailComposeResult;

@class PMMailComposeVC;
@class PMThread;
@protocol PMMailComposeVCDelegate <NSObject>
- (void)PMMailComposeVCDelegate:(PMMailComposeVC *)controller didFinishWithResult:(PMMailComposeResult)result  error:(NSError *)error;
@end

@interface PMMailComposeVC : UIViewController
@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *currentEmailAddress;
@property(nonatomic, retain) PMDraftModel *draft;
@property(nonatomic, weak) id<PMMailComposeVCDelegate> delegate;

@property(nonatomic, strong) NSMutableArray *files;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet CLTokenInputView *toTokenInputView;
@property (weak, nonatomic) IBOutlet CLTokenInputView *ccTokenInputView;
@property (weak, nonatomic) IBOutlet CLTokenInputView *bccTokenInputView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITableView *attachTableView;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UIWebView *replyBodyWebView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyBodyWebViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIWebView *eventBodyWebView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *eventBodyWebViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachTblHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactTblHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactTblTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toTokenInputViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ccTokenInputViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bccTokenInputViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bodyTextViewHeightConstraint;
@end
