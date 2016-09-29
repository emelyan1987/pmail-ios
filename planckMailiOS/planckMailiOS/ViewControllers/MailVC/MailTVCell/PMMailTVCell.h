//
//  PMMailTVCell.h
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMThread.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "PMLabel.h"

@class PMMailTVCell;
@protocol PMMailTVCellDelegate <NSObject>
- (void)btnShowOriginalPressed:(id)sender;
- (void)mailTVCell:(PMMailTVCell*)cell didChangeHeight:(CGFloat)height;
@end

@interface PMMailTVCell : MGSwipeTableCell
@property(nonatomic, weak) id<PMMailTVCellDelegate> cellDelegate;

@property (nonatomic, copy) void (^btnRSVPTapAction)(id sender);
@property (nonatomic, copy) void (^btnUnsubscribeAction)(id sender);

@property PMThread *model;



- (void)updateWithModel:(PMThread*)model;
- (void)updateWithModel:(PMThread*)model keyphrases:(NSString*)keyphrases eventInfo:(NSDictionary*)eventInfo salesforce:(BOOL)salesforce;

- (void)showBtnUnsubscribe;
-(void)showLoadingProgressBar;
-(void)hideLoadingProgressBar;


@end
