//
//  PMPhoneInputCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEmailInputCell.h"

@interface PMEmailInputCell()<UITextFieldDelegate>



@end
@implementation PMEmailInputCell

- (void)awakeFromNib {
    // Initialization code
    
    
    self.textField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnTitleTaped:(id)sender {
    if(self.btnTitleTapAction)
        self.btnTitleTapAction(sender);
}

- (IBAction)btnDeleteTaped:(id)sender
{
    if(self.btnDeleteTapAction)
        self.btnDeleteTapAction(sender);
}
- (IBAction)btnDeleteConfirmTaped:(id)sender {
    if(self.btnDeleteConfirmTapAction)
        self.btnDeleteConfirmTapAction(sender);   
    
}

- (void)bindData:(NSDictionary *)data deleteConfirmStatus:(BOOL)status
{
    //NSString *title = data[@"phone_title"];
    NSString *value = data[@"email"];
    //[self.btnTitle setTitle:title forState:UIControlStateNormal];
    [self.textField setText:value];
    
    self.contentViewLeadingConstraint.constant = status?-72:0;
}


#pragma UITextFieldDelegate Implementation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.textFieldDidChange) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.textFieldDidChange(textField, text);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
@end
