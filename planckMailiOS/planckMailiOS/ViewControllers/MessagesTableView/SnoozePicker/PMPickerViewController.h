//
//  PMPickerViewController.h
//  planckMailiOS
//
//  Created by nazar on 11/2/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMThread.h"

@protocol PMPickerViewControllerDelegate;

@interface PMPickerViewController : UIViewController

@property (nonatomic, weak) NSObject<PMPickerViewControllerDelegate> *delegate;
@property(nonatomic, strong) PMThread *inboxMailModel;

@property (nonatomic, assign) BOOL isNotifyMe;

@end

@protocol PMPickerViewControllerDelegate <NSObject>

-(void)PMPickerViewControllerDismiss:(PMPickerViewController*)viewController;
-(void)PMPickerViewController:(PMPickerViewController*)viewController setDate:(NSDate*)date autoAsk:(NSInteger)autoAsk;

@end
