//
//  PMSwitchTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSettingsSwitchTVCell.h"

@implementation PMSettingsSwitchTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchControlValueChanged:(id)sender
{
    UISwitch *switchCtrl = sender;
    
    [self.delegate switchCell:self switchControllValueChanged:switchCtrl.on];
}

@end
