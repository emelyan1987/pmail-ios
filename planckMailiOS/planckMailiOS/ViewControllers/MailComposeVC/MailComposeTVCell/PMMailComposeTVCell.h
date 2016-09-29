//
//  PMMailComposeTVCell.h
//  planckMailiOS
//
//  Created by admin on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMMailComposeTVCell;

@protocol PMMailComposeTVCellDelegate <NSObject>
- (void)PMMailComposeTVCellDelegate:(PMMailComposeTVCell *)cell
               contentTextDidChange:(NSString *)contentText;
@end

@interface PMMailComposeTVCell : UITableViewCell

+ (NSString *)identifier;

@property(nonatomic, copy) NSString *contentText;
@property(nonatomic, weak) id<PMMailComposeTVCellDelegate> delegate;

@end
