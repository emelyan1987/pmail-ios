//
//  PMActivityStatusView.h
//  planckMailiOS
//
//  Created by LionStar on 1/22/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PMActivityStatusView : NSObject

@property (nonatomic, strong) UIView *view;

-(instancetype)initFromView:(UIView*)view;
-(instancetype)initFromView:(UIView *)view textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor;
-(void)showBarWithMessage:(NSString *)message;
-(void)showBarWithMessage:(NSString *)message hideAfterDelay:(NSTimeInterval)delay;
-(void)hideBar;
@end
