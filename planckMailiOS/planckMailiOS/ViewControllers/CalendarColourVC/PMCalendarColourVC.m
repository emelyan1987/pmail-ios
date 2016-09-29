//
//  PMCalendarColourVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarColourVC.h"
#import "Config.h"
@interface PMCalendarColourVC () {
    IBOutletCollection(UIButton) NSArray *_colourBtnArray;
}
- (IBAction)colourBtnPressed:(id)sender;
- (IBAction)closeBtnPressed:(id)sender;
@end

@implementation PMCalendarColourVC

#pragma mark - PMCalendarColourVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int index = 0; index < _colourBtnArray.count; index++) {
        UIButton *itemBtn = _colourBtnArray[index];
        itemBtn.layer.cornerRadius = itemBtn.frame.size.width / 2;
        itemBtn.backgroundColor = [CALENDAR_COLORS objectAtIndex:index];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)closeBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colourBtnPressed:(id)sender {
    UIColor *lSelectedColor = ((UIButton*)sender).backgroundColor;
    CGAffineTransform start = CGAffineTransformMakeScale(1.4, 1.4);

    [UIView animateWithDuration:.4f animations:^{
        for (UIButton *itemBtn in _colourBtnArray) {
            if (itemBtn != sender) {
                itemBtn.alpha = 0;
            } else {
                itemBtn.transform = start;
            }
        }
    } completion:^(BOOL finished) {
        
        NSInteger lIndex = [CALENDAR_COLORS indexOfObject:lSelectedColor];
        _calendar.color = @(lIndex);
        [self performSelector:@selector(callFinish) withObject:nil afterDelay:0.2];
    }];
}

- (void)callFinish {
    if (_delegate && [_delegate respondsToSelector:@selector(PMCalendarColourVCDelegateColourDidChange:)]) {
        [_delegate PMCalendarColourVCDelegateColourDidChange:self];
    }
}

@end
