//
//  PMFileDriveCell.m
//  planckMailiOS
//
//  Created by LionStar on 3/31/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMFileDriveCell.h"

@interface PMFileDriveCell()
@property (weak, nonatomic) IBOutlet UILabel *lblDriveName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgChecked;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDriveNameCenterYConstraint;

@end
@implementation PMFileDriveCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(NSDictionary *)data
{
    [_imgIcon setImage:[UIImage imageNamed:data[@"icon"]]];
    
    _lblDriveNameCenterYConstraint.constant = 0;
    _lblEmailAddress.text = @"";
    _imgChecked.hidden = YES;
    
    NSString *driveName = data[@"title"];
    if([data[@"title"] isEqualToString:@"Your Mobile"])
    {
        _imgChecked.hidden = NO;
    }
    else if(data[@"email"]) {
        _lblDriveNameCenterYConstraint.constant = -12;
        
        _lblEmailAddress.text = [NSString stringWithFormat:@"(%@)", data[@"email"]];
        _imgChecked.hidden = NO;
    }
    else
    {
        driveName = [NSString stringWithFormat:@"Add %@", driveName];
    }
    
    _lblDriveName.text = driveName;
}
@end
