//
//  PMSwitchTVCell.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSwitchTVCell.h"

@interface PMSwitchTVCell ()
- (IBAction)switchStateDidChange:(id)sender;
@end

@implementation PMSwitchTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - IBAction selectors

- (void)switchStateDidChange:(id)sender {
    UISwitch *lSwitch = (UISwitch*)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(PMSwitchTVCell:stateDidChange:)]) {
        [_delegate PMSwitchTVCell:self stateDidChange:lSwitch.isOn];
    }
}

@end
