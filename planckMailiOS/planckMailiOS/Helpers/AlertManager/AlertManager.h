//
//  AlertManager.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/7/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertManager : NSObject
+(void)showErrorMessage:(NSString*)msg;
+(void)showSuccessMessage:(NSString*)msg;
+(void)showInfoMessage:(NSString*)msg;

+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message controller:(UIViewController*)viewController;

+(void)showProgressBarWithTitle:(NSString*)title view:(UIView*)view;
+(void)hideProgressBar;

/**
 *  Show activity status bar with message.
 *  @param  message: the message to show
 *  @param  type:    the type of status(ACTIVITY_STATUS_PROGRESS,ACTIVITY_STATUS_INFO,ACTIVITY_STATUS_ERROR)
 *  @param  time:    the time when this message called. if time is passed must call hideStatusBar:time method to dismiss status bar. if time is nil, after 2 secs status bar will be dismiss automatically.
 */
+(void)showStatusBarWithMessage:(NSString*)message type:(NSString*)type time:(NSDate*)time;
+(void)showStatusBarWithMessage:(NSString*)message type:(NSString*)type view:(UIView*)view time:(NSDate*)time;
+(void)hideStatusBar:(NSDate*)time;
@end
