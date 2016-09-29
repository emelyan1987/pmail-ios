//
//  PMPhoneAddCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMEmailAddCell : UITableViewCell
@property (nonatomic, copy) void (^addButtonTapAction)(id sender);
@end
