//
//  PMGystCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMGystCellDelegate <NSObject>
- (void)btnReadOriginalPressed:(NSIndexPath *)indexPath;
- (void)btnReadSummaryPressed:(NSIndexPath *)indexPath;

- (void)btnReplyPressed:(NSIndexPath *)indexPath;
- (void)btnReplyAllPressed:(NSIndexPath *)indexPath;
- (void)btnForwardPressed:(NSIndexPath *)indexPath;
@end

@interface PMGystCell : UITableViewCell
@property(nonatomic, weak) id<PMGystCellDelegate> delegate;

-(void)bindModel:(NSDictionary*)model showOriginal:(BOOL)bShowOriginal indexPath:(NSIndexPath*)indexPath;
@end
