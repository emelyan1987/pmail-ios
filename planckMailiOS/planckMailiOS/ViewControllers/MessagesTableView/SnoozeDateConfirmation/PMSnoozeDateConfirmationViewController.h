//
//  PMSnoozeDateConfirmationViewController.h
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PMSnoozeDateConfirmationControllerDelegate;

@interface PMSnoozeDateConfirmationViewController : UIViewController

@property (nonatomic, weak) NSObject<PMSnoozeDateConfirmationControllerDelegate> *delegate;

@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) BOOL isNotifyMe;
@end

@protocol PMSnoozeDateConfirmationControllerDelegate <NSObject>
-(void)PMSnoozeDateConfirmationViewControllerConfirmationAction:(PMSnoozeDateConfirmationViewController*)viewController autoAsk:(NSInteger)autoAsk;

@optional
-(void)PMSnoozeDateConfirmationViewControllerDismiss:(PMSnoozeDateConfirmationViewController*)viewController;

@end