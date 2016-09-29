//
//  PMMailComposeTVCell.m
//  planckMailiOS
//
//  Created by admin on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeTVCell.h"

@interface PMMailComposeTVCell () <UITextFieldDelegate> {
    __weak IBOutlet UITextField *_textField;
}
@end

@implementation PMMailComposeTVCell

#pragma mark - Static methods

+ (NSString *)identifier {
    return NSStringFromClass([PMMailComposeTVCell class]);
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setContentText:(NSString *)contentText {
    _contentText = contentText;
    _textField.text = _contentText;
}

#pragma mark - UITextField delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    NSMutableString *lTextString = [[NSMutableString alloc] initWithString:textField.text];
    [lTextString appendString:string];
    if (_delegate && [_delegate respondsToSelector:@selector(PMMailComposeTVCellDelegate:contentTextDidChange:)]) {
        [_delegate PMMailComposeTVCellDelegate:self contentTextDidChange:lTextString];
    }
    
    return YES;
}

@end
