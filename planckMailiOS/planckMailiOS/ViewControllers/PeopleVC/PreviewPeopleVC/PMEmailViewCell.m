//
//  PMEmailViewCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEmailViewCell.h"

@interface PMEmailViewCell()

@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;
@end
@implementation PMEmailViewCell


+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMEmailViewCell" owner:nil options:nil];
    PMEmailViewCell *cell = [cellsXIB firstObject];
    
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
    _lblEmailAddress.text = data[@"email"];
}
- (IBAction)btnMailTap:(id)sender {
    if(self.btnEmailTapAction)
        self.btnEmailTapAction(sender);
}
- (IBAction)btnCellTap:(id)sender {
    if(self.btnEmailTapAction)
        self.btnEmailTapAction(sender);
}

@end
