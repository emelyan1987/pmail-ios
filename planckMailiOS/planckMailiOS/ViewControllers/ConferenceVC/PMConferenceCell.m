//
//  PMConferenceCell.m
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMConferenceCell.h"
#import "DBSavedContact.h"
#import "PMParticipantModel.h"
#import "PMTextManager.h"
#import "NSString+Color.h"
#import "PMProfileView.h"
#import "Config.h"

#define PROFILE_VIEW_HEIGHT 40

@interface PMConferenceCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *viewParticipants;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnJoinTrailingConstraint;



@end

@implementation PMConferenceCell

- (void)awakeFromNib {
    // Initialization code
    
    
    // Set Join Button
    _btnJoin.layer.borderWidth = 1.0f;
    _btnJoin.layer.borderColor = PM_TURQUOISE_COLOR.CGColor;
    _btnJoin.layer.cornerRadius = 4.0f;
    /*CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _btnJoin.layer.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithWhite:1.0f alpha:0.1f].CGColor,
                            (id)[UIColor colorWithWhite:0.4f alpha:0.5f].CGColor,
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = _btnJoin.layer.cornerRadius;
    [_btnJoin.layer addSublayer:gradientLayer];*/
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(PMConferenceModel *)model
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"h:mm a"];
    
    _lblStartTime.text = [dateFormatter stringFromDate:model.startTime];
    _lblEndTime.text = [dateFormatter stringFromDate:model.endTime];
    
    _lblTitle.text = model.title;
    
    
    //[self performSelector:@selector(setParticipantsView:) withObject:model.participants afterDelay:0.1];
    [self setParticipantsView:model.participants];
    
    if([model.startTime timeIntervalSinceNow]<15*60)
    {
        _btnJoin.hidden = NO;
    }
    else
    {
        //_btnJoin.hidden = YES;
    }
}

//-(void)setParticipantsView:(NSArray*)participants
//{
//    for (UIView *view in self.viewParticipants.subviews) {
//        [view removeFromSuperview];
//    }
//    self.viewParticipantsHeightConstraint.constant = participants.count*48;
//    
//    CGFloat y = 0;
//    for(PMParticipantModel *participant in participants)
//    {
//        NSString *name = participant.name;
//        NSString *email = participant.email;
//        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
//        
//        UIImage *profileImage = nil;
//        if(savedContact)
//        {
//            if(savedContact.name && savedContact.name.length)
//                name = savedContact.name;
//            
//            
//            if(savedContact.profileData)
//            {
//                UIImage *image = [UIImage imageWithData:savedContact.profileData];
//                
//                if(image) profileImage = image;
//            }
//        }
//        
//        if(!name || name.length==0) name = email;
//        
//        NSString *profileLabel = [[PMTextManager shared] getLabelLettersFromText:name];
//        UIColor *profileColor = [profileLabel color];
//        
//        PMProfileView *profileView = [PMProfileView createView:15];
//        
//        [profileView setFrame:CGRectMake(8, 2, 30, 30)];
//        [profileView setBackgroundColor:profileColor];
//        if(profileImage)
//        {
//            profileView.profileImageView.image = profileImage;
//            profileView.profileImageView.hidden = NO;
//            profileView.profileLabel.hidden = YES;
//        }
//        else
//        {
//            profileView.profileImageView.hidden = YES;
//            profileView.profileLabel.hidden = NO;
//        }
//        
//        profileView.profileLabel.text = profileLabel;
//        
//        [profileView layoutIfNeeded];
//        
//        if(participant.isOrganizer) name = [NSString stringWithFormat:@"%@ (Organizer)", name];
//        UILabel *nameLabel = [[UILabel alloc] init];
//        [nameLabel setText:name];
//        [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
//        [nameLabel setTextColor:PM_GREY_COLOR];
//        [nameLabel sizeToFit];
//        
//        CGRect nameLabelFrame = nameLabel.frame;
//        [nameLabel setFrame:CGRectMake(40, (PROFILE_VIEW_HEIGHT-nameLabelFrame.size.height)/2, nameLabelFrame.size.width, nameLabelFrame.size.height)];
//        
//        CGFloat width = 8+30+2+nameLabelFrame.size.width;
//        UIView *participantView = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, PROFILE_VIEW_HEIGHT)];
//        [participantView addSubview:profileView];
//        [participantView addSubview:nameLabel];
//        [self.viewParticipants addSubview:participantView];
//        
//        y += (PROFILE_VIEW_HEIGHT + 2);
//        
//        [self.viewParticipants layoutIfNeeded];
//    }
//    
//}
-(void)setParticipantsView:(NSArray*)participants
{
    for (UIView *view in self.viewParticipants.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat height = self.viewParticipants.frame.size.height;
    CGFloat x = 0;
    for(PMParticipantModel *participant in participants)
    {
        x+=8;
        NSString *name = participant.name;
        NSString *email = participant.email;
        DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
        
        UIImage *profileImage = nil;
        if(savedContact)
        {
            if(savedContact.name && savedContact.name.length)
                name = savedContact.name;
            
            
            if(savedContact.profileData)
            {
                UIImage *image = [UIImage imageWithData:savedContact.profileData];
                
                if(image) profileImage = image;
            }
        }
        
        if(!name || name.length==0) name = email;
        
        NSString *profileLabel = [[PMTextManager shared] getLabelLettersFromText:name];
        UIColor *profileColor = [profileLabel color];
        
        PMProfileView *profileView = [PMProfileView createView:15];
        
        [profileView setFrame:CGRectMake(8, 2, 30, 30)];
        [profileView setBackgroundColor:profileColor];
        if(profileImage)
        {
            profileView.profileImageView.image = profileImage;
            profileView.profileImageView.hidden = NO;
            profileView.profileLabel.hidden = YES;
        }
        else
        {
            profileView.profileImageView.hidden = YES;
            profileView.profileLabel.hidden = NO;
        }
        
        profileView.profileLabel.text = profileLabel;
        
        [profileView layoutIfNeeded];
        
        if(participant.isOrganizer) name = [NSString stringWithFormat:@"%@ (Organizer)", name];
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setText:name];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        [nameLabel setTextColor:PM_GREY_COLOR];
        [nameLabel sizeToFit];
        
        CGRect nameLabelFrame = nameLabel.frame;
        [nameLabel setFrame:CGRectMake(40, (height-nameLabelFrame.size.height)/2, nameLabelFrame.size.width, nameLabelFrame.size.height)];
        
        CGFloat width = 8+30+2+nameLabelFrame.size.width;
        UIView *participantView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
        [participantView addSubview:profileView];
        [participantView addSubview:nameLabel];
        [self.viewParticipants addSubview:participantView];
        
        x += width;
    }
    [self.viewParticipants setContentSize:CGSizeMake(x+8, height)];
    
    
}
- (IBAction)btnJoinPressed:(id)sender {
    if(self.btnJoinTapAction)
        self.btnJoinTapAction(sender);
}
@end
