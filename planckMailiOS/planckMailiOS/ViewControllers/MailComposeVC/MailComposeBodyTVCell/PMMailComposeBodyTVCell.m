//
//  PMMailComposeBodyTVCell.m
//  planckMailiOS
//
//  Created by admin on 7/23/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeBodyTVCell.h"

@interface PMMailComposeBodyTVCell () <UITextViewDelegate> {
    __weak IBOutlet UITextView *_textView;
}
@end

@implementation PMMailComposeBodyTVCell

+ (NSString *)identifier {
    return NSStringFromClass([PMMailComposeBodyTVCell class]);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentText:(NSString *)contentText {
    _contentText = contentText;
    _textView.text = _contentText;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSMutableString *lTextString = [[NSMutableString alloc] initWithString:textView.text];
    [lTextString appendString:text];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PMMailComposeBodyTVCellDelegate:contentTextDidChange:)]) {
        [_delegate PMMailComposeBodyTVCellDelegate:self contentTextDidChange:lTextString];
    }
    
    return YES;
}

@end
