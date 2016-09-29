//
//  PMPhoneViewCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMPhoneViewCell.h"
#import "Config.h"

@interface PMPhoneViewCell()
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneTitle;

@end
@implementation PMPhoneViewCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMPhoneViewCell" owner:nil options:nil];
    PMPhoneViewCell *cell = [cellsXIB firstObject];
    
    return cell;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(NSDictionary *)data
{
    _lblPhoneNumber.text = data[kPhoneNumber];
    _lblPhoneTitle.text = data[kPhoneTitle];
}
- (IBAction)btnCallTap:(id)sender {
    if(self.btnCallTapAction)
        self.btnCallTapAction(sender);
}
- (IBAction)btnSMSTap:(id)sender {
    if(self.btnSMSTapAction)
        self.btnSMSTapAction(sender);
}
- (IBAction)btnCellTap:(id)sender {
    if(self.btnCallTapAction)
        self.btnCallTapAction(sender);
}

@end
