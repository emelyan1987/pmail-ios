//
//  PMTableViewTabBar.m
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMTableViewTabBar.h"
#import "Config.h"
#import "KxMenu.h"
#import "PMSettingsManager.h"
#define LINE_HEIGHT 3

@interface PMTableViewTabBar ()
@property (nonatomic, assign) BOOL isFilter;
@end

@implementation PMTableViewTabBar

- (void)awakeFromNib {
    [super awakeFromNib];
    _currectMessages = ImportantMessagesSelected;
    
    _importantMessagesBtn.exclusiveTouch = YES;
    _socialMessagesBtn.exclusiveTouch = YES;
    _readLaterMessageBtn.exclusiveTouch = YES;
    _followUpsMessagesBtn.exclusiveTouch = YES;
    
    _lblImportantUnreads.layer.cornerRadius = _lblImportantUnreads.frame.size.height/2;
    _lblImportantUnreads.clipsToBounds = YES;
    _lblSocialUnreads.layer.cornerRadius = _lblSocialUnreads.frame.size.height/2;
    _lblSocialUnreads.clipsToBounds = YES;
    _lblClutterUnreads.layer.cornerRadius = _lblClutterUnreads.frame.size.height/2;
    _lblClutterUnreads.clipsToBounds = YES;
    _lblReminderUnreads.layer.cornerRadius = _lblReminderUnreads.frame.size.height/2;
    _lblReminderUnreads.clipsToBounds = YES;
    
    //[self performSelector:@selector(selectInitialMessages) withObject:nil afterDelay:.1];
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [_line setFrame:CGRectMake(_importantMessagesBtn.frame.origin.x, self.frame.size.height - LINE_HEIGHT, _importantMessagesBtn.frame.size.width, LINE_HEIGHT)];
//    
//    
//}

-(void)selectInitialMessages
{
    //if([[PMSettingsManager instance] getEnabledImportant])
    {
        [self selectMessages:ImportantMessagesSelected animated:YES];
    }
//    else
//    {
//        self.importantMessagesBtn.hidden = YES;
//        self.readLaterMessageBtn.hidden = YES;
//        [self selectMessages:FollowUpsMessagesSelected animated:YES];
//    }
}
- (void)selectMessages:(selectedMessages)messages animated:(BOOL)animated {
    
    if (messages == ImportantMessagesSelected)
    {
        _lineLeadingConstraint.constant = _importantMessagesBtn.frame.origin.x;
    }
    else if (messages == SocialMessagesSelected)
    {
        _lineLeadingConstraint.constant = _socialMessagesBtn.frame.origin.x;
    }
    else if (messages == ReadLaterMessagesSelected)
    {
        _lineLeadingConstraint.constant = _readLaterMessageBtn.frame.origin.x;
    }
    else if (messages == FollowUpsMessagesSelected)
    {
        _lineLeadingConstraint.constant = _followUpsMessagesBtn.frame.origin.x;
    }
    
    [UIView animateWithDuration:animated ? .2f : .0f animations:^{
        [self layoutIfNeeded];
        
        [self.importantMessagesBtn setTitleColor:messages==ImportantMessagesSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
        [self.socialMessagesBtn setTitleColor:messages==SocialMessagesSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
        [self.readLaterMessageBtn setTitleColor:messages==ReadLaterMessagesSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
        [self.followUpsMessagesBtn setTitleColor:messages==FollowUpsMessagesSelected?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
        
        [self.importantMessagesBtn.titleLabel setFont:messages==ImportantMessagesSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        
        [self.socialMessagesBtn.titleLabel setFont:messages==SocialMessagesSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        
        [self.readLaterMessageBtn.titleLabel setFont:messages==ReadLaterMessagesSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        
        [self.followUpsMessagesBtn.titleLabel setFont:messages==FollowUpsMessagesSelected?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];

    }];
    
    _currectMessages = messages;
    
    SEL selector = @selector(messagesDidSelect:);
    if (_delegate && [_delegate respondsToSelector:selector]) {
        [_delegate messagesDidSelect:messages];
    }
}

- (void)setShow:(BOOL)bShow
{
    /*[_importantMessagesBtn setHidden:!bShow];
    [_readLaterMessageBtn setHidden:!bShow];
    [_followUpsMessagesBtn setHidden:!bShow];
    [_socialMessagesBtn setHidden:!bShow];
    [_line setHidden:!bShow];
    
    
    [_lblImportantUnreads setHidden:!bShow];
    [_lblSocialUnreads setHidden:!bShow];
    [_lblClutterUnreads setHidden:!bShow];
    [_lblReminderUnreads setHidden:!bShow];*/
    
    [_tabView setHidden:!bShow];
}

- (void)updateUnreadCount:(NSDictionary *)countData
{
    _lblImportantUnreads.hidden = YES;
    _lblSocialUnreads.hidden = YES;
    _lblClutterUnreads.hidden = YES;
    _lblReminderUnreads.hidden = YES;
    
    if(countData[@"important"])
    {
        NSInteger cnt = [countData[@"important"] integerValue];
        if(cnt)
        {
            _lblImportantUnreads.hidden = NO;
            _lblImportantUnreads.text = [NSString stringWithFormat:@" %i ",(int)cnt];
        }
    }
    if(countData[@"social"])
    {
        NSInteger cnt = [countData[@"social"] integerValue];
        if(cnt)
        {
            _lblSocialUnreads.hidden = NO;
            _lblSocialUnreads.text = [NSString stringWithFormat:@" %i ",(int)cnt];
        }
    }
    if(countData[@"clutter"])
    {
        NSInteger cnt = [countData[@"clutter"] integerValue];
        if(cnt)
        {
            _lblClutterUnreads.hidden = NO;
            _lblClutterUnreads.text = [NSString stringWithFormat:@" %i ",(int)cnt];
        }
    }
    if(countData[@"reminder"])
    {
        NSInteger cnt = [countData[@"reminder"] integerValue];
        if(cnt)
        {
            _lblReminderUnreads.hidden = NO;
            _lblReminderUnreads.text = [NSString stringWithFormat:@" %i ",(int)cnt];
        }
    }
}
- (IBAction)importantBtnTaped:(id)sender {
    [self selectMessages:ImportantMessagesSelected animated:YES];
}

- (IBAction)socialBtnTaped:(id)sender {
    [self selectMessages:SocialMessagesSelected animated:YES];
}

- (IBAction)readLaterBtnTaped:(id)sender {
    [self selectMessages:ReadLaterMessagesSelected animated:YES];
}

- (IBAction)followUpsBtnTapped:(id)sender {
    [self selectMessages:FollowUpsMessagesSelected animated:YES];
}

- (IBAction)filterBtnTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(didPressedFilterBtn:)])
        [self.delegate didPressedFilterBtn:sender];
}
@end
