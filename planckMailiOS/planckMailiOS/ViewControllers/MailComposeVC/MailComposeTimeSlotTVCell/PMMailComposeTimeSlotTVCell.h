//
//  PMMailComposeTimeSlotTVCell.h
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMMailComposeTimeSlotTVCell;
@protocol PMMailComposeTimeSlotTVCellDelegate <NSObject>
-(void)timeSlotCell:(PMMailComposeTimeSlotTVCell*)timeSlotCell didConfigureTimeSlotView:(CGFloat)height;
-(void)timeSlotCell:(PMMailComposeTimeSlotTVCell*)timeSlotCell didSelectTime:(NSTimeInterval)time;
-(void)timeSlotCell:(PMMailComposeTimeSlotTVCell*)timeSlotCell willSelectOtherTime:(id)sender;
@end

@interface PMMailComposeTimeSlotTVCell : UITableViewCell
@property (strong, nonatomic) id<PMMailComposeTimeSlotTVCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *timeSlotView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timeSlotViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *btnOtherTimes;
@property (strong, nonatomic) IBOutlet UIView *otherTimeView;
@property (strong, nonatomic) IBOutlet UILabel *otherTimeLabel;
@property (strong, nonatomic) NSDate *otherTime;

-(void)configureTimeSlotWithData:(NSDictionary*)data;
-(CGFloat)height;
@end
