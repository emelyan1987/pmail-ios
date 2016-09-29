//
//  WKContactPhonesController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactPhonesController.h"
#import "WatchKitDefines.h"
#import "WKContactPhoneRow.h"
#import "CLPerson.h"

#define CONTACT_PHONE_ROW_IDENT @"contactPhoneRow"

@interface WKContactPhonesController () {
  PMRequestType requestType;
  NSArray *phonesNumbers;
}

@property (nonatomic, weak) IBOutlet WKInterfaceTable *tableView;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *haventPhonesLabel;

@end

@implementation WKContactPhonesController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    requestType = [context[ADDITIONAL_INFO] integerValue];
    phonesNumbers = context[CONTENT];
    
    if([phonesNumbers count] == 1) {
        [self doActionForPhoneIndex:0];
    }
    if([phonesNumbers count] == 0) {
        [_haventPhonesLabel setHidden:NO];
        [_tableView setHidden:YES];
    }
    
    [self updateTableView];
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

- (void)doActionForPhoneIndex:(NSInteger)index {
  NSString *phone = phonesNumbers[index][PHONE_NUMBER]?phonesNumbers[index][PHONE_NUMBER]:@"";
  if(requestType == PMRequestMessage) {
    NSArray *preDeterminedMessages = @[@"What's Up?", @"On my way", @"OK", @"Sorry, I can't talk right now"];
    [self presentTextInputControllerWithSuggestions:preDeterminedMessages
                                   allowedInputMode:WKTextInputModeAllowEmoji
                                         completion:^(NSArray *results) {
     if([results count]) {
       [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE:@(PMWatchRequestSendSMS), WK_REQUEST_INFO: @{WK_REQUEST_PHONE: phone, WK_REQUEST_MESSAGE: results[0]}} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
           {
               
           }
       } errorHandler:^(NSError * _Nonnull error) {
           
       }];
         
     }
   }];
  } else if (requestType == PMRequestCall) {

      [[WCSession defaultSession]sendMessage:@{WK_REQUEST_TYPE:@(PMWatchRequestCall), WK_REQUEST_INFO: @{WK_REQUEST_PHONE:phone}} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
          if (replyMessage) {
              
          } else {
              
          }
      } errorHandler:^(NSError * _Nonnull error) {
          
      }];
  }
}

#pragma mark - Table view methods

- (void)updateTableView {
  [self.tableView setNumberOfRows:[phonesNumbers count] withRowType:CONTACT_PHONE_ROW_IDENT];
  
  NSInteger i = 0;
  for(NSDictionary *person in phonesNumbers) {
    WKContactPhoneRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setPhone:person[PHONE_NUMBER] label:person[PHONE_TITLE]];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self doActionForPhoneIndex:rowIndex];
}

@end



