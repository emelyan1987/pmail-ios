//
//  PMEventAlertVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventAlertVC;
@protocol PMEventAlertVCDelegate <NSObject>
- (void)PMEventAlertVCDelegate:(PMEventAlertVC *)eventAlertVC
            alertTimeDidChange:(NSDate *)date
                       message:(NSString *)message;
@end

@interface PMEventAlertVC : UIViewController
@property (nonatomic, weak) NSDate *startTime;
@property (nonatomic, weak) id<PMEventAlertVCDelegate> delegate;
@end
