//
//  PMLoginVC.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMLoginVC;

@protocol PMLoginVCDelegate <NSObject>
- (void)PMLoginVCDelegate:(PMLoginVC*)loginVC
          didSuccessLogin:(BOOL)state
        additionalAccount:(BOOL)additionalAccount;
@end

@interface PMLoginVC : UIViewController
- (IBAction)backBtnPressed:(id)sender;
- (void)setAdditionalAccoutn:(BOOL)state;

@property(nonatomic, weak) id<PMLoginVCDelegate> delegate;
@end
