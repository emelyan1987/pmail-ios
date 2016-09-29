//
//  PMTextFieldTVCell.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMTextFieldTVCell.h"

@interface PMTextFieldTVCell () <UITextFieldDelegate> {
    
}
@end

@implementation PMTextFieldTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_textField setDelegate:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_delegate PMTextFieldTVCellDelegate:self getFocus:textField];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _textField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PMTextFieldTVCellDelegate:textDidChange:)]) {
        [_delegate PMTextFieldTVCellDelegate:self textDidChange:text];
    }
    return YES;
}

@end
