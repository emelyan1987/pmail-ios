//
//  PMMailComposeBodyTVCell.h
//  planckMailiOS
//
//  Created by admin on 7/23/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMMailComposeBodyTVCell;

@protocol PMMailComposeBodyTVCellDelegate <NSObject>
- (void)PMMailComposeBodyTVCellDelegate:(PMMailComposeBodyTVCell *)cell
               contentTextDidChange:(NSString *)contentText;
@end

@interface PMMailComposeBodyTVCell : UITableViewCell

+ (NSString *)identifier;

@property(nonatomic, copy) NSString *contentText;
@property(nonatomic, weak) id<PMMailComposeBodyTVCellDelegate> delegate;


@end
