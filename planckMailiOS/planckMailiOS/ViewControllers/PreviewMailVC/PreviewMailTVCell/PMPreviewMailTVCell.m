//
//  PMPreviewMailTVCell.m
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailTVCell.h"
#import "PMTextManager.h"
#import "NSString+Color.h"
#import "NSString+Utils.h"
#import "Config.h"
#import "DBSavedContact.h"
#import "PMAPIManager.h"
#import "PMLabel.h"

#define EXPANDED_HEADER_HEIGHT 105
#define STANDARD_HEADER_HEIGHT 85

@interface PMPreviewMailTVCell () <PMPreviewContentViewDelegate>{
    
    __weak IBOutlet UIView *_headerView;
    __weak IBOutlet UIView *_profileView;
    __weak IBOutlet UILabel *_profileLabel;
    __weak IBOutlet UIImageView *_profileImageView;
    __weak IBOutlet PMLabel *_fromEmailLabel;
    __weak IBOutlet PMLabel *_toEmailLabel;
    __weak IBOutlet UILabel *_andMoreLabel;
    
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet PMLabel *_folderLabel;
    
    __weak IBOutlet UIImageView *_attachedImage;
    __weak IBOutlet PMPreviewContentView *_contentView;
    
    __weak IBOutlet UIButton *_btnReply;
    __weak IBOutlet UIView *_lessView;
    __weak IBOutlet UIView *_moreView;
    
    
    __weak IBOutlet UIButton *_btnViewToggle;
    
    __weak IBOutlet NSLayoutConstraint *_fromEmailLabelWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *_toEmailLabelWidthConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_headerViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *_moreViewHeightConstraint;
    
    NSString *fromEmailAddress;
    NSString *fromName;
    NSString *toEmailAddress;
    NSString *toName;
    
    NSNumber *expandedHeaderHeight;
}
@end

@implementation PMPreviewMailTVCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMPreviewMailTVCell" owner:nil options:nil];
    PMPreviewMailTVCell *cell = [cellsXIB firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _profileView.alpha = 0.8;
    _profileView.layer.cornerRadius = _profileView.frame.size.width/2;
    _profileView.backgroundColor = [UIColor blueColor];
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width/2;
    _profileImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGestureOnFromEmail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionOnFromEmail)];
    [_fromEmailLabel addGestureRecognizer:tapGestureOnFromEmail];
    
    UITapGestureRecognizer *tapGestureOnToEmail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionOnToEmail)];
    [_toEmailLabel addGestureRecognizer:tapGestureOnToEmail];
    
    
    _fromEmailLabel.layer.cornerRadius = _fromEmailLabel.frame.size.height/2;
    _toEmailLabel.layer.cornerRadius = _toEmailLabel.frame.size.height/2;
    _fromEmailLabel.clipsToBounds = YES;
    _toEmailLabel.clipsToBounds = YES;
    
    _folderLabel.layer.borderColor = UIColorFromRGB(0xBFBFBF).CGColor;
    _folderLabel.layer.borderWidth = 1.0f;
    _folderLabel.layer.cornerRadius = 4.0f;
    _folderLabel.clipsToBounds = YES;
}

- (void)tapActionOnFromEmail
{
    if(self.expanded)
    {
        _fromEmailLabel.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ _fromEmailLabel.alpha = 1;}
                         completion:nil];
        if(self.delegate && [self.delegate respondsToSelector:@selector(didTapOnEmail:name:sender:)])
            [self.delegate didTapOnEmail:fromEmailAddress name:fromName sender:_fromEmailLabel];
    }
}

- (void)tapActionOnToEmail
{
    if(self.expanded && toEmailAddress)
    {        
        _toEmailLabel.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ _toEmailLabel.alpha = 1;}
                         completion:nil];
        if(self.delegate && [self.delegate respondsToSelector:@selector(didTapOnEmail:name:sender:)])
            [self.delegate didTapOnEmail:toEmailAddress name:toName sender:_toEmailLabel];
    }
}

- (void)updateCellWithInfo:(NSDictionary *)dataInfo expanded:(BOOL)expanded
{
    self.dataInfo = dataInfo;
    NSTimeInterval interval = [dataInfo[@"date"] doubleValue];
    NSDate *online = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY 'at' hh:mm aaa"];
    _timeLabel.text = [dateFormatter stringFromDate:online];
    
    
    NSArray *files = dataInfo[@"files"];
    
    if(files.count>0) _attachedImage.hidden = !files.count;
    
    BOOL isInbox = NO;
    NSArray *from = (NSArray*)dataInfo[@"from"];
    
    if(from.count>0)
    {
        fromName = notNullStrValue(from[0][@"name"]);
        fromEmailAddress = from[0][@"email"];
        
        
        _fromEmailLabel.text = fromName.length ? fromName : fromEmailAddress;
        
        if(![fromEmailAddress isEqualToString:[PMAPIManager shared].emailAddress]) isInbox = YES;
        
        [self fitSizeForFromEmailLabel];
    }
    _folderLabel.text = isInbox ? @"Inbox" : @"Sent";
    
    
    NSArray *to = (NSArray*)dataInfo[@"to"];
    
    if(to && to.count)
    {
        toName = notNullStrValue(to[0][@"name"]);
        toEmailAddress = to[0][@"email"];
        
        UIColor *bgColor = CONTACT_BG_COLOR_4;
        
        DBSavedContact *toContact = [DBSavedContact getContactWithEmail:toEmailAddress];
        if(toContact)
        {
            toName = [toContact getTitle];
            
            switch ([toContact getContactTypeValue]) {
                case 1:
                    bgColor = CONTACT_BG_COLOR_1;
                    break;
                case 2:
                    bgColor = CONTACT_BG_COLOR_2;
                    break;
                case 3:
                    bgColor = CONTACT_BG_COLOR_3;
                    break;
                default:
                    bgColor = CONTACT_BG_COLOR_4;
                    break;
            }
            
        }
        
        _toEmailLabel.backgroundColor = bgColor;
        _toEmailLabel.text = toName.length ? toName : toEmailAddress;
        
        _andMoreLabel.hidden = YES;
        if(to.count>1)
        {
            _andMoreLabel.hidden = NO;
            _andMoreLabel.text = [NSString stringWithFormat:@"...and %i more", (int)to.count];
        }
        
        [self fitSizeForToEmailLabel];
        
    }
    
    
    NSString *bodyText = dataInfo[@"body"];
    
    BOOL haveToSummarize = YES;
    NSArray *events = dataInfo[@"events"];
    
    if(events.count)
    {
        haveToSummarize = NO;
        
        NSDictionary *event = events[0];
        
        __weak PMPreviewMailTVCell *weakCell = self;
        __weak NSString *eventId = event[@"id"];
        _contentView.btnRSVPTapAction = ^(id sender) {
            if([weakCell.delegate respondsToSelector:@selector(didTapBtnRSVP:eventId:)])
                [weakCell.delegate didTapBtnRSVP:sender eventId:eventId];
        };
    }
    [_contentView showDetail:bodyText files:files messageId:dataInfo[@"id"] haveToSummarize:haveToSummarize];
    _contentView.delegate = self;
    
    
    // Setting profile view
    NSString *circleLabelText = [[PMTextManager shared] getLabelLettersFromText:fromName.length?fromName:fromEmailAddress];
    _profileLabel.text = circleLabelText;
    
    CGFloat labelColor = [circleLabelText LabelColor];
    CGFloat hue = labelColor;//( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = 1.0;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = 0.8;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    _profileView.backgroundColor = color;
    
    _profileImageView.hidden = YES;
    
    UIColor *fromEmailBgColor = CONTACT_BG_COLOR_4;
    DBSavedContact *contact = [DBSavedContact getContactWithEmail:fromEmailAddress];
    
    if(contact)
    {
        if(contact.profileData)
        {
            UIImage *profileImage = [UIImage imageWithData:contact.profileData];
            if(profileImage)
            {
                _profileImageView.image = profileImage;
                _profileImageView.hidden = NO;
            }
        }
        
        switch ([contact getContactTypeValue]) {
            case 1:
                fromEmailBgColor = CONTACT_BG_COLOR_1;
                break;
            case 2:
                fromEmailBgColor = CONTACT_BG_COLOR_2;
                break;
            case 3:
                fromEmailBgColor = CONTACT_BG_COLOR_3;
                break;
            default:
                fromEmailBgColor = CONTACT_BG_COLOR_4;
                break;
        }
        
        
    }
    _fromEmailLabel.backgroundColor = fromEmailBgColor;
    
    
}

- (void)expand
{    
    _btnReply.hidden = NO;
    self.expanded = YES;
    
    if(_dataInfo)
    {
        NSInteger mailsCount = ((NSArray*)_dataInfo[@"to"]).count+((NSArray*)_dataInfo[@"cc"]).count+((NSArray*)_dataInfo[@"bcc"]).count;
        
        if(mailsCount>1)
        {
            _btnViewToggle.hidden = NO;
            CGFloat height = ([_btnViewToggle.titleLabel.text isEqualToString:@"View more"] && expandedHeaderHeight) ? [expandedHeaderHeight floatValue] : EXPANDED_HEADER_HEIGHT;
            _headerViewHeightConstraint.constant = height;
            
            return;
        }
    }
    
    _btnViewToggle.hidden = YES;
    _headerViewHeightConstraint.constant = STANDARD_HEADER_HEIGHT;
}
- (void)collapse
{
    _btnViewToggle.hidden = YES;
    _headerViewHeightConstraint.constant = STANDARD_HEADER_HEIGHT;
    
    _btnReply.hidden = YES;
    
    self.expanded = NO;
}
- (NSInteger)height:(BOOL)expanded
{
    CGFloat headerHeight = _headerViewHeightConstraint.constant;
    CGFloat contentHeight = [_contentView contentHeight];
    
    return headerHeight + (expanded?contentHeight:0);
}

#pragma PMPreviewContentCellDelegate

-(void)didSelectAttachment:(NSDictionary *)file
{
    [_delegate didSelectAttachment:file];
}

-(void)didLoadContent
{
    [_delegate didChangedCellHeight:self];
}

- (void)fitSizeForToEmailLabel {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    CGSize toEmailSize = [_toEmailLabel.text sizeWithFont:_toEmailLabel.font];
    CGFloat toEmailWidth = toEmailSize.width + 10;
    
    CGFloat toEmailDelta = screenSize.width - 90 - _lessView.frame.origin.x - _toEmailLabel.frame.origin.x - toEmailWidth;
    if(toEmailDelta<0) toEmailWidth += (toEmailDelta-8);
    
    _toEmailLabelWidthConstraint.constant = toEmailWidth;
}

- (void)fitSizeForFromEmailLabel {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    CGSize fromEmailSize = [_fromEmailLabel.text sizeWithFont:_fromEmailLabel.font];
    CGFloat fromEmailWidth = fromEmailSize.width + 10;
    
    CGFloat fromEmailDelta = screenSize.width - _fromEmailLabel.frame.origin.x - fromEmailWidth;
    if(fromEmailDelta<0) fromEmailWidth += (fromEmailDelta-8);
    
    _fromEmailLabelWidthConstraint.constant = fromEmailWidth;
}


- (CGFloat)addEmailLabels:(NSArray*)emails mark:(NSString*)mark offsetY:(CGFloat)offsetY
{
    CGFloat MARK_LABEL_WIDTH = 30;
    CGFloat MARGIN_X = 2;
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MARK_LABEL_WIDTH, 21)];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [label setTextColor:PM_GREY_COLOR];
    label.text = mark;
    [view addSubview:label];
    
    UIView *emailView = [[UIView alloc] init];
    
    CGFloat x = 0, y = 0;
    
    CGFloat emailLabelHeight = 0.0, emailLabelWidth;
    for(NSDictionary *item in emails) {
        PMLabel *emailLabel = [[PMLabel alloc] init];
        [emailLabel setFont:_toEmailLabel.font];
        
        [emailLabel setTextColor:[UIColor whiteColor]];
        
        NSString *email = item[@"email"];
        NSString *name = nil;
        
        UIColor *bgColor = CONTACT_BG_COLOR_4;
        
        DBSavedContact *contact = [DBSavedContact getContactWithEmail:email];
        if(contact)
        {
            name = [contact getTitle];
            
            switch ([contact getContactTypeValue]) {
                case 1:
                    bgColor = CONTACT_BG_COLOR_1;
                    break;
                case 2:
                    bgColor = CONTACT_BG_COLOR_2;
                    break;
                case 3:
                    bgColor = CONTACT_BG_COLOR_3;
                    break;
                default:
                    bgColor = CONTACT_BG_COLOR_4;
                    break;
            }
        }
        
        [emailLabel setBackgroundColor:bgColor];
        
        name = name&&name.length?name:notNullValue(item[@"name"]);
        NSString *title = name&&name.length?name:email;
        
        [emailLabel setText:title];
        CGSize emailLabelSize = [title sizeWithFont:emailLabel.font];
        
        emailLabelWidth = emailLabelSize.width; emailLabelHeight = emailLabelSize.height;
        
        DLog(@"MoreView Frame Size:%f,%f", _moreView.frame.size.width, _moreView.frame.size.height);
        
        CGFloat maxWidth = _moreView.frame.size.width-2*MARGIN_X-MARK_LABEL_WIDTH;
        if(emailLabelWidth > maxWidth)
        {
            x = 0;
            [emailLabel setFrame:CGRectMake(2, y+2, maxWidth, emailLabelSize.height)];
            
            y += emailLabelHeight + 2;
        }
        else if(x+emailLabelWidth+10+2*MARGIN_X < maxWidth)
        {
            [emailLabel setFrame:CGRectMake(x+2, y+2, emailLabelWidth+10, emailLabelSize.height)];
            
            x += (emailLabelSize.width+12);
        }
        else
        {
            x = 0; y += (emailLabelHeight + 2);
            
            
            [emailLabel setFrame:CGRectMake(x+2, y+2, emailLabelSize.width+10, emailLabelSize.height)];
            
            x += (emailLabelSize.width+12);
        }
        
        emailLabelHeight = emailLabelSize.height;
        emailLabel.layer.cornerRadius = emailLabelHeight/2;
        emailLabel.clipsToBounds = YES;
        
        [emailView addSubview:emailLabel];
    }
    
    [emailView setFrame:CGRectMake(30, 0, _moreView.frame.size.width-30, y+emailLabelHeight+2)];
    
    [view addSubview:emailView];
    
    [view setFrame:CGRectMake(0, offsetY, _moreView.frame.size.width, emailView.frame.size.height)];
    
    [_moreView addSubview:view];
    
    return view.frame.size.height + 2;
}
- (IBAction)btnViewToggleClicked:(id)sender {
    DLog(@"Header View Height:%f", _headerViewHeightConstraint.constant);
    
    if([_btnViewToggle.titleLabel.text isEqualToString:@"View more"])
    {
        _lessView.hidden = YES; _moreView.hidden = NO;
        
        CGFloat height = 0;
        
        NSArray *to = _dataInfo[@"to"];
        if(to && to.count)
        {
            height += [self addEmailLabels:to mark:@"To:" offsetY:height];
        }
        NSArray *cc = _dataInfo[@"cc"];
        if(cc && cc.count)
        {
            height += [self addEmailLabels:cc mark:@"Cc:" offsetY:height];
        }
        NSArray *bcc = _dataInfo[@"bcc"];
        if(bcc && bcc.count)
        {
            height += [self addEmailLabels:bcc mark:@"Bcc:" offsetY:height];
        }
        
        //    UIButton *btnLess = [[UIButton alloc] initWithFrame:CGRectMake(_moreView.frame.size.width - 62, height-20, 62, 25)];
        //    [btnLess.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        //    [btnLess setTitle:@"View less" forState:UIControlStateNormal];
        //    [btnLess setTitleColor:PM_TURQUOISE_COLOR forState:UIControlStateNormal];
        //    [btnLess addTarget:self action:@selector(btnLessClicked:) forControlEvents:UIControlEventTouchUpInside];
        //    [_moreView addSubview:btnLess];
        //
        //    height += 7;
        
        _moreViewHeightConstraint.constant = height;
        
        CGFloat newHeight = _fromEmailLabel.frame.origin.y + _fromEmailLabel.frame.size.height + _moreViewHeightConstraint.constant + 2 + 30;
        _headerViewHeightConstraint.constant = newHeight;
        
        expandedHeaderHeight = [NSNumber numberWithFloat:newHeight];
        
        [_btnViewToggle setTitle:@"View less" forState:UIControlStateNormal];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didTapBtnMore:)])
            [self.delegate didTapBtnMore:self];
    }
    else
    {
        _headerViewHeightConstraint.constant = EXPANDED_HEADER_HEIGHT;
        
        _lessView.hidden = NO;
        _moreView.hidden = YES;
        
        [_btnViewToggle setTitle:@"View more" forState:UIControlStateNormal];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didTapBtnMore:)])
            [self.delegate didTapBtnMore:self];
    }
    
}

- (IBAction)btnReplyClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(didTapBtnReply:messageData:)])
        [self.delegate didTapBtnReply:sender messageData:_dataInfo];
}

- (BOOL)toggled
{
    if([_btnViewToggle.titleLabel.text isEqualToString:@"View more"]) return NO;
    return YES;
}
@end
