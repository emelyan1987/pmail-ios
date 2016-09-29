//
//  PMMailComposeEventVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMMailEventModel.h"

@protocol PMMailComposeEventVCDelegate <NSObject>

-(void)didCancelEditEvent;
-(void)didDoneEditEvent:(PMMailEventModel*)eventModel;

@end

@interface PMMailComposeEventVC : UIViewController
@property (strong, nonatomic) id<PMMailComposeEventVCDelegate> delegate;
@property (strong, nonatomic) PMMailEventModel *eventModel;


@end
