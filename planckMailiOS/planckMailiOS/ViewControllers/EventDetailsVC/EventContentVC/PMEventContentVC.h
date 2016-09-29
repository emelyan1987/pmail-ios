//
//  PMEventContentVC.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@class PMEventContentVC;

@protocol PMEventContentVCDelegate <NSObject>
-(void)eventContentVCDidAppear:(PMEventContentVC*)contentVC;
@end

@interface PMEventContentVC : UIViewController
@property(nonatomic, strong) id<PMEventContentVCDelegate> delegate;
- (void)updateWithEvent:(PMEventModel*)event;
@property(nonatomic, assign) NSInteger pageIndex;

@property(nonatomic, strong) PMEventModel *currentEvent;

@end
