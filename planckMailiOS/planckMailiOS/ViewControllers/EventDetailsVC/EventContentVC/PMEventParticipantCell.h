//
//  PMEventParticipantCell.h
//  planckMailiOS
//
//  Created by LionStar on 2/3/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMParticipantModel.h"
@interface PMEventParticipantCell : UITableViewCell

-(void)bindModel:(PMParticipantModel*)model;
-(void)setOrganizerLabel;
@end
