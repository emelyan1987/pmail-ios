//
//  PMMailTVCell.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailTVCell.h"
#import "NSDate+DateConverter.h"
#import "DBThread.h"
#import "PMAPIManager.h"
#import "PMMailManager.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+DateConverter.h"
#import "config.h"
#import "PMThread+Extended.h"

@interface PMMailTVCell () {
    __weak IBOutlet UIImageView *_attachedFileImageView;
    __weak IBOutlet UIImageView *_unreadImageView;
    __weak IBOutlet UIImageView *_replyImageView;
    __weak IBOutlet UIImageView *_calendarImageView;
    __weak IBOutlet UIImageView *_salesforceImageView;
    __weak IBOutlet UIImageView *_clockImageView;
    __weak IBOutlet UILabel *_personNameLabel;
    __weak IBOutlet UILabel *_titleNameLabel;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UILabel *_eventDayLabel;
    IBOutlet PMLabel *countLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *_eventTimeLabel;
    __weak IBOutlet NSLayoutConstraint *topMarginContraint;
    
    __weak IBOutlet NSLayoutConstraint *_personNameLabelLeadingConstraint;
    __weak IBOutlet NSLayoutConstraint *_personNameLabelWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *_salesforceImgWidthConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_countLabelWidthConstraint;
    __weak IBOutlet UIButton *btnRSVP;
    __weak IBOutlet UIButton *btnShowOriginal;
    __weak IBOutlet UIButton *btnUnsubscribe;
    
    
    UIView *trackView;
    UIView *progressView;
    NSString *keyphrasesString;
    
    BOOL isLoading;
}
@end

@implementation PMMailTVCell

- (void)awakeFromNib {
    // Initialization code
    btnShowOriginal.layer.borderWidth = 1.0f;
    btnRSVP.layer.borderWidth = 1.0f;
    
    btnShowOriginal.layer.borderColor = UIColorFromRGB(0xc9e3f3).CGColor;
    btnRSVP.layer.borderColor = PM_TURQUOISE_COLOR.CGColor;
    
    
    btnShowOriginal.layer.cornerRadius = 4.0f;
    btnRSVP.layer.cornerRadius = 4.0f;
    
    countLabel.layer.borderWidth = 1.0f;
    countLabel.layer.cornerRadius = 4.0f;
    countLabel.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)updateWithModel:(PMThread *)model {
    _attachedFileImageView.hidden = !model.hasAttachments;
    _unreadImageView.hidden = !model.isUnread;
    _replyImageView.hidden = ![model isReply];
    
    //nsdate *lNewDate = [NSDate dateWithTimeIntervalSince1970:model.]
    
    timeLabel.hidden = NO;
    timeLabel.text = [model.lastMessageDate relativeDateTimeString];
    
    _personNameLabel.text = [model getParticipantNames];
    if(model.isUnread)
        _personNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    else
        _personNameLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    
    _titleNameLabel.text = model.subject;
    
    
    descriptionLabel.text = model.snippet;
    
    if(model.messagesCount>1) {
        countLabel.hidden = NO;
        countLabel.text = [NSString stringWithFormat:@"%d", (int)model.messagesCount];
    }
    else
    {
        countLabel.hidden = YES;
        countLabel.text = @"";
    }
    
    if(model.isUnread)
    {
        countLabel.layer.borderColor = [UIColor colorWithRed:157.0/255.0f green:195.0/255.0f blue:230.0/255.0f alpha:1.0f].CGColor;
        countLabel.textColor = countLabel.backgroundColor = [UIColor colorWithRed:157.0/255.0f green:195.0/255.0f blue:230.0/255.0f alpha:0.3f];
    }
    else
    {
        countLabel.layer.borderColor = [UIColor colorWithRed:191.0/255.0f green:191.0/255.0f blue:191.0/255.0f alpha:1.0f].CGColor;
        countLabel.backgroundColor = [UIColor whiteColor];
        countLabel.textColor = [UIColor colorWithRed:191.0/255.0f green:191.0/255.0f blue:191.0/255.0f alpha:1.0f];
    }
    
    [countLabel sizeToFit];
    
}

- (void)updateWithModel:(PMThread *)model keyphrases:(NSString*)keyphrases eventInfo:(NSDictionary*)eventInfo salesforce:(BOOL)salesforce {
    _attachedFileImageView.hidden = !model.hasAttachments;
    _unreadImageView.hidden = !model.isUnread;
    _replyImageView.hidden = ![model isReply];
    
    //nsdate *lNewDate = [NSDate dateWithTimeIntervalSince1970:model.]
    
    timeLabel.hidden = NO; timeLabel.text = [model.lastMessageDate relativeDateTimeString];
    
    _titleNameLabel.text = model.subject;
    
    
    _personNameLabel.text = [model getParticipantNames];
    
    if(model.isUnread)
        _personNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    else
        _personNameLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    if(model.messagesCount>1) {
        countLabel.text = [NSString stringWithFormat:@"%d", (int)model.messagesCount];
        
        
        
        if(model.isUnread)
        {
            countLabel.layer.borderColor = [UIColor colorWithRed:157.0/255.0f green:195.0/255.0f blue:230.0/255.0f alpha:1.0f].CGColor;
            countLabel.backgroundColor = [UIColor colorWithRed:157.0/255.0f green:195.0/255.0f blue:230.0/255.0f alpha:0.3f];
            countLabel.textColor = [UIColor colorWithRed:157.0/255.0f green:195.0/255.0f blue:230.0/255.0f alpha:1.0f];
        }
        else
        {
            countLabel.layer.borderColor = [UIColor colorWithRed:191.0/255.0f green:191.0/255.0f blue:191.0/255.0f alpha:1.0f].CGColor;
            countLabel.backgroundColor = [UIColor whiteColor];
            countLabel.textColor = [UIColor colorWithRed:191.0/255.0f green:191.0/255.0f blue:191.0/255.0f alpha:1.0f];
        }
        
        [countLabel sizeToFit];
        _countLabelWidthConstraint.constant = countLabel.frame.size.width;
    }
    else
    {
        countLabel.text = @"";
        _countLabelWidthConstraint.constant = 0;
    }
    
    
    if(keyphrases!=nil)
    {
        descriptionLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.5f];
        descriptionLabel.text = keyphrases;
    }
    else
    {
        descriptionLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.5f];
        descriptionLabel.text = model.snippet;
    }
    
    btnShowOriginal.hidden = keyphrases==nil;
    
    
    _calendarImageView.hidden = YES;
    _personNameLabelLeadingConstraint.constant = 2;
    _clockImageView.hidden = YES;
    _eventTimeLabel.hidden = YES;
    _eventDayLabel.hidden = YES;
    btnRSVP.hidden = YES;
    _salesforceImageView.hidden = YES;
    
    if(eventInfo)
    {
        _calendarImageView.hidden = NO;
        _personNameLabelLeadingConstraint.constant = 30;
        
        NSString *status = eventInfo[@"status"];
        
        if([status isEqualToString:@"noreply"])
        {
            _clockImageView.hidden = NO;
            _eventTimeLabel.hidden = NO;
            _eventDayLabel.hidden = NO;
            btnRSVP.hidden = NO;
            
            NSDate *startTime = eventInfo[@"start_time"];
            NSDate *endTime = eventInfo[@"end_time"];
            
            _eventTimeLabel.text = [NSString stringWithFormat:@"%@ at %@(%d mins)", [startTime readableDateString], [startTime readableTimeString], (int)[endTime timeIntervalSinceDate:startTime]/60];
            _eventDayLabel.text = [NSString stringWithFormat:@"%d", (int)[startTime getDay]];
            
            if([self.cellDelegate respondsToSelector:@selector(mailTVCell:didChangeHeight:)])
                [self.cellDelegate mailTVCell:self didChangeHeight:120];
        }
    }
    
    if(salesforce)
    {
        _salesforceImageView.hidden = NO;
        _salesforceImgWidthConstraint.constant = 25;
    }
    else
    {
        _salesforceImgWidthConstraint.constant = 0;
    }
    
    
    btnUnsubscribe.hidden = YES;
    
    // adjust labels width
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = iOSScreenSize.width;
    //[_personNameLabel sizeToFit];
    
    CGFloat maxWidth = screenWidth - _personNameLabelLeadingConstraint.constant  - timeLabel.frame.size.width - 4 - _countLabelWidthConstraint.constant - 5 - _salesforceImgWidthConstraint.constant - 5 - 20;
    
    CGFloat personNameLabelWidth = [_personNameLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]].width;
    
    if(personNameLabelWidth>maxWidth)
        _personNameLabelWidthConstraint.constant = maxWidth;
    else
        _personNameLabelWidthConstraint.constant = personNameLabelWidth;
    
    [self layoutIfNeeded];
    self.model = model;
}


-(void)showLoadingProgressBar
{
    //topMarginContraint.constant = 5;
    
    isLoading = YES;
    
    trackView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.frame.size.width, 3)];
    trackView.backgroundColor = [UIColor colorWithRed:129.0f/255.0f green:228.0f/255.0f blue:203.0f/255.0f alpha:1.0];
    
    [self addSubview:trackView];
    
    progressView = [[UIView alloc] initWithFrame:CGRectMake(-200, 1, 200, 3)];
    progressView.backgroundColor = [UIColor colorWithRed:0 green:204.0f/255.0f blue:153.0f/255.0f alpha:1.0];
    [trackView addSubview:progressView];
    
    
    
    
    
    
    [self animateProgressView:progressView];
    
    
    
}
-(void)animateProgressView:(UIView *)view
{
    [view setFrame:CGRectMake(-200, 1, 200, 2)];
    
    [UIView animateWithDuration:0.7
                     animations:^{
                         [view setFrame:CGRectMake(trackView.frame.size.width, 1, 200, 2)];
                     }
                     completion:^(BOOL finished) {
                         if(isLoading) [self animateProgressView:view];
                     }];
}
-(void)hideLoadingProgressBar
{
    isLoading = NO;
    if(trackView) [trackView removeFromSuperview];
    //topMarginContraint.constant = 0;
}

- (void)showBtnUnsubscribe
{
    btnUnsubscribe.hidden = NO;
}
- (IBAction)btnShowOriginalPressed:(id)sender {
    [_cellDelegate btnShowOriginalPressed:self];
}

- (IBAction)btnRSVPPressed:(id)sender
{
    if(self.btnRSVPTapAction)
        self.btnRSVPTapAction(sender);
}
- (IBAction)btnUnsubscribePressed:(id)sender {
    if(self.btnUnsubscribeAction)
        self.btnUnsubscribeAction(sender);

}

@end
