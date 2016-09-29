//
//  PMEventContentTitleCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/4/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMEventModel.h"

@interface PMEventContentTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *colorMarkView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

-(void)setEvent:(PMEventModel*)event;
@end
