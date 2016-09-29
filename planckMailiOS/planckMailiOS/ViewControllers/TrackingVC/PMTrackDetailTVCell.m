//
//  PMTrackDetailTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMTrackDetailTVCell.h"

@interface PMTrackDetailTVCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblActorEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIImageView *imgDevice;

@end
@implementation PMTrackDetailTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindData:(NSDictionary *)detailData
{
    _lblActorEmail.text = detailData[@"actor_email"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY HH:mm a"];
    _lblTime.text = [dateFormatter stringFromDate:detailData[@"created_time"]];
    
    _lblDetails.text = detailData[@"location"]&&((NSString*)detailData[@"location"]).length?detailData[@"location"]:@"Unknown";
    
    UIImage *icon = nil;
    NSString *actionType = detailData[@"action_type"];
    if([actionType isEqualToString:@"O"])
        icon = [UIImage imageNamed:@"opened"];
    else
        icon = [UIImage imageNamed:@"clicked"];
    
    _imgIcon.image = icon;
    
    UIImage *deviceImage = nil;
    if(detailData[@"is_mobile"] && [detailData[@"is_mobile"] boolValue]==YES)
        deviceImage = [UIImage imageNamed:@"mobile"];
    else
        deviceImage = [UIImage imageNamed:@"desktop"];
    
    [_imgDevice setImage:deviceImage];
}

- (IBAction)btnCallTap:(id)sender {
}
- (IBAction)btnEmailTap:(id)sender {
}

@end
