//
//  PMConferenceCell.h
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMConferenceModel.h"

@interface PMConferenceCell : UITableViewCell

@property (nonatomic, copy) void (^btnJoinTapAction)(id sender);
-(void)bindModel:(PMConferenceModel*)model;
@end
