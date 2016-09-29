//
//  PMUnsubscribeTVC.m
//  planckMailiOS
//
//  Created by LionStar on 3/5/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMUnsubscribeTVC.h"

@interface PMUnsubscribeTVC()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
@implementation PMUnsubscribeTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(NSDictionary *)data selected:(BOOL)selected
{
    NSString *name = notNullStrValue(data[@"name"]);
    self.titleLabel.text = name&&name.length ? name : @"(No Name)";
    self.emailLabel.text = data[@"email"];
    self.countLabel.text = data[@"count"]?[NSString stringWithFormat:@"%@", data[@"count"]]:@"";
    
    if(selected)
        self.iconImageView.image = [UIImage imageNamed:@"checked.png"];
    else
        self.iconImageView.image = [UIImage imageNamed:@"unchecked.png"];
}
@end
