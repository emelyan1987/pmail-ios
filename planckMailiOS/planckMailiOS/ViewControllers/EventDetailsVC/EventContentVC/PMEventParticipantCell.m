//
//  PMEventParticipantCell.m
//  planckMailiOS
//
//  Created by LionStar on 2/3/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEventParticipantCell.h"
#import "DBSavedContact.h"
#import "PMTextManager.h"
#import "NSString+Color.h"

@interface PMEventParticipantCell()
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PMEventParticipantCell

- (void)awakeFromNib {
    // Initialization code
    
    _profileView.alpha = 0.8;
    _profileView.layer.cornerRadius = _profileView.frame.size.width/2;
    _profileView.backgroundColor = [UIColor greenColor];
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width/2;
    _profileImageView.clipsToBounds = YES;
    
    _statusView.layer.borderWidth = 2.0f;
    _statusView.layer.borderColor = [UIColor whiteColor].CGColor;
    _statusView.layer.cornerRadius = _statusView.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(PMParticipantModel *)model
{
    // Setting profile view
    NSString *name = model.name;
    NSString *email = model.email;
    DBSavedContact *contact = [DBSavedContact getContactWithEmail:email];
    
    if(contact) name = [contact getTitle];
    NSString *profileLabelText = [[PMTextManager shared] getLabelLettersFromText:name.length?name:email];
    _profileLabel.text = profileLabelText;
    
    CGFloat labelColor = [profileLabelText LabelColor];
    CGFloat hue = labelColor;//( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = 1.0;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = 0.8;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    _profileView.backgroundColor = color;
    
    _profileImageView.hidden = YES;
    
    if(contact && contact.profileData)
    {
        UIImage *profileImage = [UIImage imageWithData:contact.profileData];
        if(profileImage)
        {
            _profileImageView.image = profileImage;
            _profileImageView.hidden = NO;
            _profileLabel.hidden = YES;
        }
    }
    
    _statusView.hidden = YES;
    
    if([model.status isEqualToString:@"yes"])
    {
        _statusView.hidden = NO;
        _statusView.backgroundColor = [UIColor greenColor];
    }
    else if([model.status isEqualToString:@"no"])
    {
        _statusView.hidden = NO;
        _statusView.backgroundColor = [UIColor redColor];
    }
    else if([model.status isEqualToString:@"maybe"])
    {
        _statusView.hidden = NO;
        _statusView.backgroundColor = [UIColor lightGrayColor];
    }
    
    
    _nameLabel.text = name;
    _emailLabel.text = email;
    
    if(model.isOrganizer) [self setOrganizerLabel];
}

-(void)setOrganizerLabel
{
    NSString *name = [NSString stringWithFormat:@"%@ (Organizer)", _nameLabel.text];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:name];

    NSRange range = NSMakeRange(name.length-11, 11);
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
    
    [_nameLabel setAttributedText:attributeString];
}
@end
