//
//  PMSFLeadTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFLeadTVCell.h"

@interface PMSFLeadTVCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end
@implementation PMSFLeadTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindItem:(NSDictionary *)itemData
{
    [_lblName setText:itemData[@"Name"]];
    [_lblCompany setText:itemData[@"Company"]];
    [_lblTitle setText:itemData[@"Title"]];
}
@end
