//
//  PMActivityStatusView.m
//  planckMailiOS
//
//  Created by LionStar on 1/22/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMActivityStatusView.h"

#define BAR_HEIGHT 30

@interface PMActivityStatusView()

@property UIView *statusView;
@property UILabel *statusLabel;

@end
@implementation PMActivityStatusView

-(instancetype)initFromView:(UIView *)view
{
    self = [super init];
    if(self!=nil)
    {
        self.view = view;
        
        CGRect viewFrame = self.view.frame;
        self.statusView = [[UIView alloc] initWithFrame:CGRectMake(0, viewFrame.size.height-49, viewFrame.size.width, 0)];
        self.statusView.clipsToBounds = YES;
        
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [UIColor redColor];
        self.statusLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.statusView addSubview:self.statusLabel];
        
        [self.statusView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0], [NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    }
    
    return self;
}

-(instancetype)initFromView:(UIView *)view textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor
{
    self = [self initFromView:view];
    [self.statusView setBackgroundColor:backgroundColor];
    [self.statusLabel setTextColor:textColor];
    return self;
}

-(void)showBarWithMessage:(NSString *)message
{
    
    [self.statusView removeFromSuperview];
    
    self.statusLabel.text = message;
    [self.statusLabel sizeToFit];
    
    CGRect viewFrame = self.view.frame;
    
    CGRect statusViewFrame = CGRectMake(0, viewFrame.size.height-49, viewFrame.size.width, 0);
    
    [self.statusView setFrame:statusViewFrame];
    
    
    [self.view addSubview:self.statusView];
    
    
    [UIView animateWithDuration:.3 animations:^{
        [self.statusView setFrame:CGRectMake(0, statusViewFrame.origin.y-BAR_HEIGHT, statusViewFrame.size.width, BAR_HEIGHT)];
    }];
    
}

-(void)showBarWithMessage:(NSString *)message hideAfterDelay:(NSTimeInterval)delay
{
    [self.statusView removeFromSuperview];
    
    self.statusLabel.text = message;
    [self.statusLabel sizeToFit];
    
    CGRect viewFrame = self.view.frame;
    
    CGRect statusViewFrame = CGRectMake(0, viewFrame.size.height-49, viewFrame.size.width, 0);
    
    [self.statusView setFrame:statusViewFrame];
    
    
    [self.view addSubview:self.statusView];
    
    
    [UIView animateWithDuration:.3 animations:^{
        [self.statusView setFrame:CGRectMake(0, statusViewFrame.origin.y-BAR_HEIGHT, statusViewFrame.size.width, BAR_HEIGHT)];
    }];
    
    [self performSelector:@selector(hideBar) withObject:nil afterDelay:delay];
}

-(void)hideBar
{
    CGRect messageViewFrame = self.statusView.frame;
    [UIView animateWithDuration:.3 animations:^{
        [self.statusView setFrame:CGRectMake(0, messageViewFrame.origin.y+BAR_HEIGHT, messageViewFrame.size.width, 0)];
    }];
}

@end
