//
//  PMArchivedMailUndoCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/5/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMArchivedMailUndoCell : UITableViewCell
+(instancetype)newCell;

@property (nonatomic, copy) void (^archivedButtonTapAction)(id sender);
@property (nonatomic, copy) void (^undoButtonTapAction)(id sender);
@end
