//
//  PMEventInviteesVC.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMEventInviteesVCDelegate <NSObject>
-(void)didSelectPeoples:(NSArray*)peoples;
@end
@interface PMEventInviteesVC : UIViewController

@property(nonatomic, weak) id<PMEventInviteesVCDelegate> delegate;

@property(nonatomic, strong) NSArray *peoples;
@end
