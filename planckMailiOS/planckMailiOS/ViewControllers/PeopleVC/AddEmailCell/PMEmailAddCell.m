//
//  PMPhoneAddCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEmailAddCell.h"

@implementation PMEmailAddCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)btnAddClicked:(id)sender {
    if(self.addButtonTapAction)
        self.addButtonTapAction(sender);
}
- (IBAction)btnAddEmailClicked:(id)sender {
    if(self.addButtonTapAction)
        self.addButtonTapAction(sender);
}

@end
