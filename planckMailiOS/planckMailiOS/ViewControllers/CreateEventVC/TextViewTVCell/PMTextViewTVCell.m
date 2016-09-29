//
//  PMTextViewTVCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/30/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMTextViewTVCell.h"

@implementation PMTextViewTVCell

- (void)awakeFromNib {
    // Initialization code
    [_textView setDelegate:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma UITextViewDelegate implements
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(PMTextViewTVCellDelegate:getFocus:)]) {
        [_delegate PMTextViewTVCellDelegate:self getFocus:textView];
    }
    
    if([textView.text isEqualToString:@"Description"])
    {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0)
    {
        textView.text = @"Description";
        textView.textColor = [UIColor lightGrayColor];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PMTextViewTVCellDelegate:textDidChange:)]) {
        [_delegate PMTextViewTVCellDelegate:self textDidChange:string];
    }
    return YES;
}
@end
