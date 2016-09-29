//
//  PMCreateEventTVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMEventModel.h"

@protocol PMCreateEventVCDelegate <NSObject>

-(void)didCreateEvent;
-(void)didUpdateEvent;
-(void)didDeleteEvent:(PMEventModel*)eventModel;
@end
@interface PMCreateEventVC : UIViewController
@property(nonatomic, strong) id<PMCreateEventVCDelegate> delegate;

@property(nonatomic, assign) BOOL isUpdate;
@property(nonatomic, strong) PMEventModel *eventModel;
@end
