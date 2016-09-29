//
//  PMInviteesTVCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/30/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMInviteesTVCell.h"
#import "CLTokenInputView.h"
#import "DBContact.h"
#import "DBSavedContact.h"

@interface PMInviteesTVCell() <CLTokenInputViewDelegate>
@property (weak, nonatomic) IBOutlet CLTokenInputView *tokenInputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tivHeightConstraint;


@end
@implementation PMInviteesTVCell

- (void)awakeFromNib {
    // Initialization code
    _tokenInputView.delegate = self;
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    _tokenInputView.font = font;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPeoples:(NSArray *)peoples
{
    NSArray *tokens = self.tokenInputView.allTokens;
    if(tokens && tokens.count>0)
    {
        for(CLToken *token in tokens)
        {
            [self.tokenInputView removeToken:token];
        }
    }
    
    if(peoples && peoples.count>0)
    {
        for(NSDictionary *people in peoples)
        {
            NSString *email = people[@"email"];
            DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
                        
            NSString *displayText = ([people[@"name"] isEqual:[NSNull null]] || ((NSString*)people[@"name"]).length)==0?people[@"email"]:people[@"name"];
            if(savedContact && savedContact.name && savedContact.name.length) displayText = savedContact.name;
            
            NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
            CLToken *token = [[CLToken alloc] initWithDisplayText:displayText context:people type:type];
            [self.tokenInputView addToken:token];
        }
    }
}
-(CGFloat)height
{
    return self.tivHeightConstraint.constant + 2;
}
#pragma mark CLTokenInputViewDelegate

-(void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height
{
    
    self.tivHeightConstraint.constant = height;
    
    [self layoutIfNeeded];
}
@end
