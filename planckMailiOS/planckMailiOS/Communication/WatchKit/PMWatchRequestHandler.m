//
//  PMWatchRequestHandler.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMWatchRequestHandler.h"
#import "AppDelegate.h"
#import "WatchKitDefines.h"
#import "DBManager.h"
#import "PMTypeContainer.h"
#import "PMAPIManager.h"
#import "PMThread.h"
#import "CLContactLibrary.h"
#import <MessageUI/MessageUI.h>
#import "PMCalendarVC.h"
#import <JTCalendar/JTCalendar.h>
#import "PMEventModel.h"

#import "DBSavedContact.h"
#import "DBManager.h"

#import "Config.h"
#import "PMFileManager.h"
#import "PMPhotoManager.h"
#import "PMTextManager.h"

@import WatchConnectivity;

@interface PMWatchRequestHandler () <APContactLibraryDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, JTCalendarDelegate>
{
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    NSInteger _offset;
    
}

@property (nonatomic, strong) NSMutableArray *eventsArray;


@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (nonatomic, copy) void (^replyBlock)(NSDictionary *);

@end

@implementation PMWatchRequestHandler

+ (instancetype)sharedHandler {
    static PMWatchRequestHandler *sharedHandler = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedHandler = [PMWatchRequestHandler new];
    });
    
    return sharedHandler;
}

- (void)handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSInteger requestType = [userInfo[WK_REQUEST_TYPE] integerValue];
        
        switch (requestType) {
            case PMWatchRequestAccounts: {
                NSArray *lNamespacesArray = [[DBManager instance] getNamespaces];
                
                NSMutableArray *typesArray = [NSMutableArray new];
                for(DBNamespace *nameSpace in lNamespacesArray) {
                    PMTypeContainer *typeNamespace = [PMTypeContainer initWithNameSpase:nameSpace];
                    typeNamespace.unreadCount = [[DBManager instance] getUnreadCountWithAccountId:nameSpace.account_id];
                    [typesArray addObject:[NSKeyedArchiver archivedDataWithRootObject: typeNamespace]];                    
                    
                }
                
                if(reply) {
                    reply(@{WK_REQUEST_RESPONSE: typesArray});
                }
            }
                
                break;
                
            case PMWatchRequestGetEmails: {
                if(userInfo[WK_REQUEST_INFO]) {
                    PMTypeContainer *account = [NSKeyedUnarchiver unarchiveObjectWithData:userInfo[WK_REQUEST_INFO]];
                    NSArray *emails =
                    [[PMAPIManager shared] getThreadsWithAccount:account.namespace_id
                                                        folder:@"inbox"
                                                        offset:[userInfo[WK_REQUEST_EMAILS_LIMIT]unsignedIntegerValue]
                                                                limit:EMAILS_LIMIT_COUNT ];
                    if(reply) {
                        NSMutableArray *archivedEmails = [NSMutableArray new];
                        for(PMThread *email in emails) {
                            [archivedEmails addObject:[NSKeyedArchiver archivedDataWithRootObject:email]];
                        }
                        reply(@{WK_REQUEST_RESPONSE: archivedEmails});
                    }
                }
            }
                
                break;
                
            case PMWatchRequestReply: {
                NSMutableDictionary *replyDict = [NSMutableDictionary dictionaryWithDictionary:userInfo[WK_REQUEST_INFO]];
                [[PMAPIManager shared] replyMessage:replyDict completion:^(id data, id error, BOOL success) {
                    if(reply) {
                        reply(@{WK_REQUEST_RESPONSE: [NSNumber numberWithBool:success]});
                    }
                }];
            }
                
                break;
                
            case PMWatchRequestGetEmailDetails: {
                PMThread *mailModel = [NSKeyedUnarchiver unarchiveObjectWithData:userInfo[WK_REQUEST_INFO]];
                NSArray *messages = [[PMAPIManager shared] getMessagesWithThreadId:mailModel.id
                                                      forAccount:mailModel.accountId
                                                   completion:^(id data, id error, BOOL success) {
                                                       
                                                   }];
                
                if(reply) {
                    id result = messages;
                    reply(result);
                }
            }
                
                break;
                
            case PMWatchRequestGetContacts: {
                self.replyBlock = reply;                
                
                NSArray *dbSavedContacts = [[DBManager instance] getSavedContactsWithType:CONTACT_TYPE_PHONE offset:0 limit:200];
                    
                NSMutableArray *data = [NSMutableArray new];
                for(DBSavedContact *contact in dbSavedContacts) {
                    NSDictionary *contactData = @{@"id": contact.id, @"name": [contact getTitle]};
                    
                    
                    [data addObject:contactData];
                }
                
                [[WCSession defaultSession] transferUserInfo:@{WK_CONTACT_LIST:data}];
                
                
                
                
                /*if(reply) {
                    reply(@{WK_REQUEST_RESPONSE: data});
                }*/
            }
                break;
                
            case PMWatchRequestGetContactInfo: {
                self.replyBlock = reply;
                
                //[[CLContactLibrary sharedInstance] getPersonForContactNames:userInfo[WK_REQUEST_INFO] forDelegate:self];
                
                NSString *contactId = userInfo[WK_REQUEST_INFO];
                DBSavedContact *contact = [DBSavedContact getContactWithId:contactId];
                
                
                NSMutableDictionary *contactDict = [NSMutableDictionary dictionaryWithDictionary:[contact convertToDictionary]];
                [contactDict removeObjectForKey:@"profile_data"];
                
                if(contact.profileData)
                {
                    /*NSString *groupPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID].path;
                    
                    NSString *imagePath = [groupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", contact.id]];
                    
                    [contact.profileData writeToFile:imagePath atomically:YES];*/
                    
                    NSString *profilePath = [PMFileManager ThumbnailDirectory:@"profile"];
                    NSString *imagePath = [profilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", contact.id]];
                    
                    UIImage *profileImage = [UIImage imageWithData:contact.profileData];
                    UIImage *reducedImage = [PMPhotoManager squareImageFromImage:profileImage scaledToSize:40];
                    
                    NSData *reducedData = UIImageJPEGRepresentation(reducedImage, 50);
                    [reducedData writeToFile:imagePath atomically:YES];
                    
                    NSURL *url = [NSURL fileURLWithPath:imagePath];
                    
                    WCSessionFileTransfer *fileTransfer = [[WCSession defaultSession] transferFile:url metadata:nil];
                }
                
                if(reply) {
                    reply(@{WK_REQUEST_RESPONSE: contactDict});
                }
            }
                
                break;
                
            case PMWatchRequestCall: {
                NSString *lPhoneString = [NSString stringWithFormat:@"tel:%@", [[PMTextManager shared] getCallablePhoneNumber:userInfo[WK_REQUEST_INFO][WK_REQUEST_PHONE]]];
                NSString *urlString = [lPhoneString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *lUrl = [[NSURL alloc] initWithString:urlString];
                [[UIApplication sharedApplication] openURL:lUrl];
            }
                
                break;
                
            case PMWatchRequestSendSMS: {
                self.replyBlock = reply;
                NSDictionary *info = userInfo[WK_REQUEST_INFO];
                
                MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                if([MFMessageComposeViewController canSendText])
                {
                    controller.body = info[WK_REQUEST_MESSAGE];
                    controller.recipients = [NSArray arrayWithObjects:info[WK_REQUEST_PHONE], nil];
                    controller.messageComposeDelegate = self;
                    [((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController presentViewController:controller animated:YES completion:^{
                        
                    }];
                }
            }
                
            case PMWatchRequestGetUnreadEmailsCount: {
                NSString *token = userInfo[WK_REQUEST_INFO];
                if(token) {
                    [[PMAPIManager shared] getUnreadCountForNamespaseToken:token completion:^(id data, id error, BOOL success) {
                        NSDictionary *result = [NSDictionary new];
                        if(!error && data) {
                            result = @{WK_REQUEST_RESPONSE: data};
                        }
                        if(reply) {
                            reply(result);
                        }
                    }];
                }
            }
                break;
                
            case PMWatchRequestGetUnreadEmails: {
                
            }
                break;
                
            case PMWatchRequestGetEvents: {
                
//                if (reply) {
//                    reply(@{WK_REQUEST_RESPONSE: @"as"});
//                }
                
                _offset = 0;
                
                _calendarManager = [JTCalendarManager new];
                _calendarManager.delegate = self;
                _calendarManager.settings.weekModeEnabled = YES;
                
                self.eventsArray = [NSMutableArray array];
                [self createMinAndMaxDate];
                NSDictionary *eventParams = @{
                                              @"starts_after" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_minDate]],
                                              @"ends_before" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_maxDate]],
                                              @"expand_recurring" : @"true",
                                              @"limit" : @10,
                                              @"offset" : @(_offset)
                                              };
                __weak typeof(self)__self = self;
                
//                [[PMAPIManager shared] getTheadWithAccount:[[PMAPIManager shared] namespaceId] completion:^(id error, BOOL success) {
//                    
//                }];
                NSArray *events = [[PMAPIManager shared] getEventsWithAccount:[[PMAPIManager shared] namespaceId].account_id eventParams:eventParams comlpetion:^(id data, id error, BOOL success) {

                    /*NSMutableArray *archivedEvents = [NSMutableArray new];
                    for(PMEventModel *event in data) {
                        [archivedEvents addObject:[NSKeyedArchiver archivedDataWithRootObject:event]];
                    }
                    
                                    if (reply) {
                                        reply(@{WK_REQUEST_RESPONSE: archivedEvents});
                                    }
                    
                    if (!error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            __self.eventsArray = data;
                            
                            
                            _offset = __self.eventsArray.count;
                            
                        });
                        
                    }*/
                }];
                
                NSMutableArray *archivedEvents = [NSMutableArray new];
                for(PMEventModel *event in events) {
                    NSDictionary *eventDict = [event convertDictionary];
                    [archivedEvents addObject:eventDict];
                }
                
                
                if (reply) {
                    reply(@{WK_REQUEST_RESPONSE: archivedEvents});
                }
                
            }
                break;
                
                break;
                
            default:
                break;
        }
        
    });
}

- (NSTimeInterval)timeStampWithDate:(NSDate*)date {
    return [date timeIntervalSince1970];
}

- (void)createMinAndMaxDate {
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-3];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:12];
}


#pragma mark - APContactLibraryDelegate

- (void)apGetContactArray:(NSArray *)contactArray {
    NSMutableArray *personsArray = nil;
    NSDictionary *response = nil;
    
    if(contactArray) {
        personsArray = [NSMutableArray new];
        for(CLPerson *person in contactArray) {
            [personsArray addObject:[NSKeyedArchiver archivedDataWithRootObject:person]];
        }
        
        response = @{WK_REQUEST_RESPONSE: personsArray};
    }
    
    if(_replyBlock) {
        _replyBlock(response);
    }
}

- (void)getNamesOfContacts:(NSArray *)contactsNames {
    NSMutableArray *personsArray = nil;
    NSDictionary *response = nil;
    
    if(contactsNames) {
        personsArray = [NSMutableArray new];
        for(NSDictionary *person in contactsNames) {
            [personsArray addObject:[NSKeyedArchiver archivedDataWithRootObject:person]];
        }
        
        response = @{WK_REQUEST_RESPONSE: personsArray};
    }
    
    if(_replyBlock) {
        _replyBlock(response);
    }
}

- (void)getPersonForNames:(CLPerson *)person {
    NSDictionary *response = @{WK_REQUEST_RESPONSE: [NSKeyedArchiver archivedDataWithRootObject:person]};
    
    if(_replyBlock) {
        _replyBlock(response);
    }
}

- (BOOL)shouldScaleImage {
    return YES;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    BOOL status = (result == MessageComposeResultSent);
    _replyBlock(@{WK_REQUEST_RESPONSE: [NSNumber numberWithBool:status]});
}

@end
