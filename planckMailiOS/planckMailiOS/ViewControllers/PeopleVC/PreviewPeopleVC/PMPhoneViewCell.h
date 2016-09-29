//
//  PMPhoneViewCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMPhoneViewCell : UITableViewCell

@property (nonatomic, copy) void (^btnCallTapAction)(id sender);
@property (nonatomic, copy) void (^btnSMSTapAction)(id sender);
+ (instancetype)newCell;

- (void)bindData:(NSDictionary*)data;
@end
