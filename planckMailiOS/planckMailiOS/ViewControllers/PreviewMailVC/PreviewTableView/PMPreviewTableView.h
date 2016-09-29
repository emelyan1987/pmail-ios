//
//  PMPreviewTableView.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/10/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMThread;
@protocol PMPreviewTableViewDelegate;
@interface PMPreviewTableView : UIView

@property(nonatomic, strong) PMThread *inboxMailModel;
@property(nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, assign) CGFloat lastRowHeight;

@property (nonatomic, weak) id <PMPreviewTableViewDelegate> delegate;

+ (instancetype)newPreviewView;

@end

@protocol PMPreviewTableViewDelegate <NSObject>

- (void)PMPreviewTableView:(PMPreviewTableView *)previewTable didUpdateMessages:(NSArray *)messages;
- (void)PMPreviewTableViewDelegateShowAlert:(PMPreviewTableView *)messagesTableView inboxMailModel:(PMThread*)mailModel;
- (void)didSelectAttachment:(NSDictionary *)file;
- (void)onGystAction:(NSArray*)messages;
- (void)didTapOnEmail:(NSString*)email name:(NSString*)name sender:(id)sender;
- (void)didTapBtnRSVP:(UIButton*)sender eventId:(NSString *)eventId;
- (void)didTapUnsubscribeButton:(id)sender model:(PMThread*)model;
- (void)didTapBtnFlag:(UIButton*)sender thread:(PMThread*)thread;
- (void)didTapBtnReply:(UIButton*)sender messageData:(NSDictionary*)data;

@end
