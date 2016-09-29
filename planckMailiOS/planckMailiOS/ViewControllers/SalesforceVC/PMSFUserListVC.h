//
//  PMSFUserListVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSFUserListVC;
@protocol PMSFUserListVCDelegate <NSObject>
-(void)userListVC:(PMSFUserListVC*)vc didSelectUser:(NSDictionary*)userData;
@end
@interface PMSFUserListVC : UIViewController

@property (nonatomic, strong) id<PMSFUserListVCDelegate> delegate;
@end
