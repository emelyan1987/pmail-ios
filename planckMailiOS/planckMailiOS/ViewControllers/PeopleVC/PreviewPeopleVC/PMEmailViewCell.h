//
//  PMEmailViewCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMEmailViewCell : UITableViewCell

@property (nonatomic, copy) void (^btnEmailTapAction)(id sender);

+ (instancetype)newCell;

- (void)bindData:(NSDictionary*)data;
@end
