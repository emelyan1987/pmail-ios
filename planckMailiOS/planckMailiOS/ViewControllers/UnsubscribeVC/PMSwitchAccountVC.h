//
//  PMSwitchAccountVC.h
//  planckMailiOS
//
//  Created by LionStar on 4/12/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBNamespace.h"


@protocol PMSwitchAccountVCDelegate <NSObject>
- (void)dismissSwitchAccountVCWithSelectedAccount:(DBNamespace*)account;
@end
@interface PMSwitchAccountVC : UIViewController

@property (nonatomic, strong) id<PMSwitchAccountVCDelegate> delegate;
@property (nonatomic, strong) DBNamespace *selectedAccount;
@end
