//
//  WKSelectedAnswerController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@import WatchConnectivity;

#define REPLY_TEXT @"reply_text"
#define REPLY_MESSAGE_INFO @"reply_message_info"

#define SELECTED_ANSWER_IDENTIFIER @"selectedAnswer"
#define SELECTED_ANSWER_RETAKE @"selectedAnswerRetake"

@interface WKSelectedAnswerController : WKInterfaceController <WCSessionDelegate>

@end
