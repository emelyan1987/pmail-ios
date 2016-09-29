//
//  WKEmailController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailController.h"
#import "PMThread.h"
#import "WKSelectedAnswerController.h"
#import "NSDate+DateConverter.h"
#import "WatchKitDefines.h"
@import UIKit;
#define SEGUE_GO_TO_REPLAY @"goToReplyIdentifier"

@interface WKEmailController () {
  PMThread *emailContainer;
  BOOL retakePressed;
  NSDictionary *emailInfo;
}


@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;

@end

@implementation WKEmailController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context) {
    emailContainer = (PMThread *)context[CONTENT];
    emailInfo = context[ADDITIONAL_INFO];
    [self.titleLabel setText:emailContainer.ownerName];
    [self.subjectLabel setText:emailContainer.subject];
    
      
      if ([WCSession isSupported]) {
          WCSession *session = [WCSession defaultSession];
          session.delegate = self;
          [session activateSession];
          
          if(emailInfo) {
              [self showActivityIndicator:NO];
              [self updateBodyAndDate];
          } else {
              [self showActivityIndicator:YES];
              NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:emailContainer];
              [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO: emailData} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                  //remove htmp tags
                  @autoreleasepool {
                      emailContainer.isUnread = NO;
                      if([replyMessage isKindOfClass:[NSArray class]]) {
                          emailInfo = [[((NSArray *)replyMessage) firstObject] copy];
                      } else {
                          emailInfo = [replyMessage copy];
                      }
                      
                      [self updateBodyAndDate];
                      [self showActivityIndicator:NO];
                      //
                      //                [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                      //                    <#code#>
                      //                } errorHandler:^(NSError * _Nonnull error) {
                      //
                      //                }];
                  }
                  
              } errorHandler:^(NSError * _Nonnull error) {
                  
              }];
              
          }
      }
  }
}

- (void) updateBodyAndDate {
  NSString *htmlBody = emailInfo[@"body"];
  NSAttributedString *textBody = [[NSAttributedString alloc] initWithData:[htmlBody dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
  [self.textLabel setText:textBody.string];
  
  NSTimeInterval date = [emailInfo[@"date"] doubleValue];
  NSDate *online = [NSDate dateWithTimeIntervalSince1970:date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"MMM dd, YYYY 'at' hh:mm aaa"];
  
  [self.dateLabel setText:[dateFormatter stringFromDate:online]];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
  if([segueIdentifier isEqualToString:SEGUE_GO_TO_REPLAY]) {
    return emailContainer;
  }
  return nil;
}

- (IBAction)replyDidPressed {
  NSArray *preDeterminedMessages = @[@"OK", @"Thanks", @"Got it", @"Running late", @"On my way", @"I will get back to you soon", @"Sounds good", @"I am on it", @"Yes", @"No", @"+1"];
  [self presentTextInputControllerWithSuggestions:preDeterminedMessages
                                 allowedInputMode:WKTextInputModeAllowEmoji
                                       completion:^(NSArray *results) {
    if([results count]) {
      
      [self pushControllerWithName:SELECTED_ANSWER_IDENTIFIER
                           context:@{REPLY_TEXT: [results firstObject], REPLY_MESSAGE_INFO: emailInfo}];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retakePressedNotification:) name:SELECTED_ANSWER_RETAKE object:nil];
    }
  }];
}

- (void)retakePressedNotification:(NSNotification *)notification {
  retakePressed = YES;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    
    
  
  if(retakePressed) {
    [self replyDidPressed];
  }
  retakePressed = NO;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



