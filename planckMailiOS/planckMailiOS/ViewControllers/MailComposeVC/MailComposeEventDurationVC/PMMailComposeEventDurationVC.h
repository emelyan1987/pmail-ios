//
//  PMEventAlertVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMMailComposeEventDurationVC;
@protocol PMMailComposeEventDurationVCDelegate <NSObject>

- (void)eventDurationVC:(PMMailComposeEventDurationVC *)eventDurationVC
      didSelectDuration:(NSInteger)duration; //minuntes
@end

@interface PMMailComposeEventDurationVC : UIViewController
@property (nonatomic, weak) NSDate *startTime;
@property (nonatomic, weak) id<PMMailComposeEventDurationVCDelegate> delegate;
@end
