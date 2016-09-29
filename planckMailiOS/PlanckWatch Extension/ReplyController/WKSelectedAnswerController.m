//
//  WKSelectedAnswerController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKSelectedAnswerController.h"
#import "WatchKitDefines.h"

@interface WKSelectedAnswerController () {
  NSDictionary *replyDict;
}
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *answerLabel;

@end

@implementation WKSelectedAnswerController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];

  if(context) {
    replyDict = context;
    [_answerLabel setText:replyDict[REPLY_TEXT]];
  }
}

- (IBAction)sendDidPressed {
  if(replyDict[REPLY_TEXT]) {
    NSDictionary *messageInfo = replyDict[REPLY_MESSAGE_INFO];
    NSDictionary *reply = @{@"reply_to_message_id": messageInfo[@"id"],
                            @"body" : replyDict[REPLY_TEXT],
                            @"to": messageInfo[@"from"]};
    
      [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestReply), WK_REQUEST_INFO: reply} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
          
      } errorHandler:^(NSError * _Nonnull error) {
          
      }];
      
    [self popController];
  }
}

- (IBAction)retakeDidPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:SELECTED_ANSWER_RETAKE object:nil];
  [self popController];
}

- (IBAction)cancelDidPressed {
  [self popController];
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to user
  [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end
