//
//  WKContactInfoController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactInfoController.h"
#import "WKContactPhonesController.h"
#import "WatchKitDefines.h"
#import "CLPerson.h"
#import "Config.h"

@interface WKContactInfoController () {
  //CLPerson *person;
    NSDictionary *contactData;
}

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *personName;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *personImage;

@property (nonatomic, weak) IBOutlet WKInterfaceButton *callButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *messageButton;

@end

@implementation WKContactInfoController

- (instancetype)initWithContactNames:(NSDictionary *)names {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        
        NSString *contactId = context;
        if(contactId)
            [self loadContactData:contactId];
    }
    
    
    
}

- (void)willActivate {
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadContactData:(NSString*)contactId
{
    [self showActivityIndicator:YES];
    
    if(contactId) {
        [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE:@(PMWatchRequestGetContactInfo),
                                                  WK_REQUEST_INFO: contactId} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                                                      NSDictionary *responceObj = replyMessage[WK_REQUEST_RESPONSE];
                                                      if(responceObj) {
                                                          contactData = responceObj;
                                                          
                                                          
                                                          [self updateUserInfo:contactData];
                                                      }
                                                      
                                                      [self showActivityIndicator:NO];
                                                  } errorHandler:^(NSError * _Nonnull error) {
                                                      [self showActivityIndicator:NO];
                                                      
                                                      NSLog(@"error = %@", error);
                                                  }];
        
    }
}
- (void)updateUserInfo:(NSDictionary*)data {
    NSArray *phoneNumbers = data[@"phone_numbers"];
    
    [_callButton setEnabled:phoneNumbers.count];
    [_messageButton setEnabled:phoneNumbers.count];
    
    [_personName setText:data[@"name"]];
    
    
    /*NSString *groupPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID].path;
    
    NSString *imagePath = [groupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", data[@"id"]]];

    if([[NSFileManager defaultManager] fileExistsAtPath: groupPath]){
        UIImage *image = [[UIImage alloc] initWithContentsOfFile: @"/private/var/mobile/Containers/Shared/AppGroup/F46815C5-CC61-4E4D-9E40-AA48E9289A40/phone-45.png"];
        
        if(image) {
            [_personImage setImage:image];
        }
    }*/
}

#pragma mark WKSessionDelegate

-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file
{
    NSString *imagePath = file.fileURL.path;
    NSData *imageData = [NSData dataWithContentsOfURL:file.fileURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    if(image)
    {
        [_personImage setBackgroundImage:image];
    }
}
#pragma mark - User actions

- (IBAction)callDidPressed:(id)sender {
  NSArray *numbers = contactData[@"phone_numbers"];
  if(!numbers) {
    numbers = @[];
  }
  [self presentControllerWithName:CONTACTS_PHONE_IDENT
                          context:@{CONTENT: numbers, ADDITIONAL_INFO: @(PMRequestCall)}];
}

- (IBAction)messageDidPressed:(id)sender {
  NSArray *numbers = contactData[@"phone_numbers"];
  if(!numbers) {
    numbers = @[];
  }
  [self presentControllerWithName:CONTACTS_PHONE_IDENT
                          context:@{CONTENT: numbers, ADDITIONAL_INFO: @(PMRequestMessage)}];
}

@end



