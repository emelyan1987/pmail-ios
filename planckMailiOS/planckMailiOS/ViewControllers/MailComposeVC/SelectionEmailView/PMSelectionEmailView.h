//
//  PMSelectionEmailView.h
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+PMViewCreator.h"

@class PMSelectionEmailView;

@protocol PMSelectionEmailViewDelegate <NSObject>
- (void)PMSelectionEmailViewDelegate:(PMSelectionEmailView*)view didSelectEmail:(NSString *)emeil;
@end

@interface PMSelectionEmailView : UIView
- (void)showInView:(UIView *)view;
- (void)setEmails:(NSArray *)emails;

@property(nonatomic, weak) id<PMSelectionEmailViewDelegate> delegate;
@end
