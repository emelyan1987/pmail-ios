//
//  PMEventRSVPCell.h
//  planckMailiOS
//
//  Created by LionStar on 2/3/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMEventRSVPCell : UITableViewCell

@property (nonatomic, copy) void (^btnRSVPTapAction)(id sender);
-(void)bindData:(NSString*)data;
@end
