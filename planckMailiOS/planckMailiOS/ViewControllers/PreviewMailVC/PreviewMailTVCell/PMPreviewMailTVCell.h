//
//  PMPreviewMailTVCell.h
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPreviewContentView.h"

@class PMPreviewMailTVCell;

@protocol PMPreviewMailTVCellDelegate <NSObject>
-(void)didSelectAttachment:(NSDictionary *)file;
-(void)didLoadContent:(PMPreviewMailTVCell*)cell;
-(void)didTapBtnMore:(PMPreviewMailTVCell*)cell;
-(void)didTapBtnLess:(PMPreviewMailTVCell*)cell;
-(void)didTapOnEmail:(NSString*)email name:(NSString*)name sender:(id)sender;
-(void)didTapBtnRSVP:(UIButton *)sender eventId:(NSString*)eventId;
-(void)didTapBtnReply:(UIButton *)sender messageData:(NSDictionary*)data;
-(void)didChangedCellHeight:(PMPreviewMailTVCell*)cell;
@end
@interface PMPreviewMailTVCell : UITableViewCell

@property(nonatomic, weak) id<PMPreviewMailTVCellDelegate> delegate;

+ (instancetype)newCell;

- (void)updateCellWithInfo:(NSDictionary *)dataInfo expanded:(BOOL)expanded;
- (NSInteger)height:(BOOL)expanded;
- (void)expand;
- (void)collapse;

- (BOOL)toggled;

@property NSDictionary *dataInfo;
@property (nonatomic, assign) BOOL expanded;


@end
