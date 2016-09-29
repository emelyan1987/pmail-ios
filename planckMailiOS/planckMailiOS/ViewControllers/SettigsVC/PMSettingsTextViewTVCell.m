//
//  PMSettingsTextViewTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSettingsTextViewTVCell.h"

@interface PMSettingsTextViewTVCell()<UITextViewDelegate>

@end
@implementation PMSettingsTextViewTVCell

- (void)awakeFromNib {
    // Initialization code
    self.textView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewCell:textDidChange:)]) {
        [self.delegate textViewCell:self textDidChange:[NSString stringWithFormat:@"%@%@", textView.text, text]];
    }
    return YES;
}
@end
