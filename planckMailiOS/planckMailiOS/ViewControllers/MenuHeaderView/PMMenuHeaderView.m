//
//  PMMenuHeaderView.m
//  planckMailiOS
//
//  Created by admin on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMenuHeaderView.h"
#import "PMAccountManager.h"
#import "Config.h"

@interface PMMenuHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAccount;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblProvider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblEmailCenterYConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnCollapse;
@property (weak, nonatomic) IBOutlet UIButton *btnExpand;
- (IBAction)headerBntPressed:(id)sender;
@end

@implementation PMMenuHeaderView

- (void)headerBntPressed:(id)sender {
    self.selected = !_selected;
    if (_delegate && [_delegate respondsToSelector:@selector(PMMenuHeaderView:selectedState:)]) {
        [_delegate PMMenuHeaderView:self selectedState:_selected];
    }
    
    
}


- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    if(_selected)
    {
        //_lblEmail.textColor = [UIColor whiteColor];
    }
    else
    {
        //_lblEmail.textColor = [UIColor lightGrayColor];
    }
}
-(void)expand
{
    _btnCollapse.hidden = NO;
    _btnExpand.hidden = YES;
}
-(void)collapse
{
    _btnCollapse.hidden = YES;
    _btnExpand.hidden = NO;
}

-(void)setTitle:(NSString *)title forProvider:(NSString *)provider
{    
    self.imgViewAccount.image = [UIImage imageNamed:[[PMAccountManager sharedManager] iconNameByProvider:provider]];
    self.lblEmail.text = title;
    
    if(provider)
    {
        self.lblProvider.text = [provider capitalizedString];
        self.lblEmailCenterYConstraint.constant = -9;
    }
    else
    {
        self.lblProvider.text = nil;
        self.lblEmailCenterYConstraint.constant = 0;
    }
}
- (IBAction)btnExpandPressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(PMMenuHeaderView:expanded:)])
        [self.delegate PMMenuHeaderView:self expanded:YES];
}
- (IBAction)btnCollapsePressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(PMMenuHeaderView:expanded:)])
        [self.delegate PMMenuHeaderView:self expanded:NO];
}

@end
