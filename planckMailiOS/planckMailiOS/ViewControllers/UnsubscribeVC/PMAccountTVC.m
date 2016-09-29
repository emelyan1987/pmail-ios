//
//  PMAccountTVC.m
//  planckMailiOS
//
//  Created by LionStar on 4/12/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMAccountTVC.h"

@interface PMAccountTVC()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end
@implementation PMAccountTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEmail:(NSString *)email selected:(BOOL)selected
{
    self.emailLabel.text = email;
    
    if(selected)
        self.iconImageView.image = [UIImage imageNamed:@"selected"];
    else
        self.iconImageView.image = [UIImage imageNamed:@"unselected"];
}
@end
