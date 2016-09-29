//
//  PMEventRSVPCell.m
//  planckMailiOS
//
//  Created by LionStar on 2/3/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEventRSVPCell.h"
#import "Config.h"

@interface PMEventRSVPCell()

@property (weak, nonatomic) IBOutlet UIView *bulletView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnRSVP;
@end
@implementation PMEventRSVPCell

- (void)awakeFromNib {
    // Initialization code
    
    _btnRSVP.layer.borderWidth = 1.0f;
    _btnRSVP.layer.borderColor = UIColorFromRGB(0xc9e3f3).CGColor;
    _btnRSVP.layer.cornerRadius = 4.0f;
    
    _bulletView.layer.cornerRadius = _bulletView.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindData:(NSString *)status
{
    if([status isEqualToString:@"yes"])
    {
        _bulletView.backgroundColor = [UIColor greenColor];
        _statusLabel.text = @"You are going.";
    }
    else if([status isEqualToString:@"no"])
    {
        _bulletView.backgroundColor = [UIColor redColor];
        _statusLabel.text = @"You have declined.";
    }
    else if([status isEqualToString:@"maybe"])
    {
        _bulletView.backgroundColor = [UIColor lightGrayColor];
        _statusLabel.text = @"You are tentative.";
    }
    else if([status isEqualToString:@"noreply"])
    {
        _bulletView.backgroundColor = [UIColor blueColor];
        _statusLabel.text = @"You are busy.";
    }
}

-(IBAction)btnRSVPPressed:(id)sender
{
    if(self.btnRSVPTapAction)
        self.btnRSVPTapAction(sender);
}
@end
