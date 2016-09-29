//
//  PMContactCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactCell.h"
#import "Config.h"

@interface PMContactCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;

@end
@implementation PMContactCell

- (void)awakeFromNib {
    // Initialization code
    
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width/2;
    _profileImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindContact:(DBSavedContact *)contact
{
    NSString *name = contact.name;
    DLog(@"Length of name:%i",name.length);
    NSData *profileData = contact.profileData;
    
    _lblName.text = name;
    _lblEmail.text = [contact getFirstEmailAddress];
    
    UIImage *image;
    if(profileData)
    {
        image = [UIImage imageWithData:profileData];
        
    }
    else
    {
        image = [UIImage imageNamed:@"profile"];
    }
    [_profileImageView setImage:image];
    
    UIImage *typeImage;
    NSString *contactType = [contact getContactType];
    if([contactType isEqualToString:CONTACT_TYPE_EMAIL])
        typeImage = [UIImage imageNamed:@"contact_email"];
    else if([contactType isEqualToString:CONTACT_TYPE_PHONE])
        typeImage = [UIImage imageNamed:@"contact_phone"];
    else if([contactType isEqualToString:CONTACT_TYPE_SALESFORCE])
        typeImage = [UIImage imageNamed:@"contact_salesforce"];
    
    [_typeImageView setImage:typeImage];
}
@end
