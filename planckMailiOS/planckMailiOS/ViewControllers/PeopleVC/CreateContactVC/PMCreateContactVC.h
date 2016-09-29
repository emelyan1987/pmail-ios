//
//  PMCreateContactVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "DBSavedContact.h"

@protocol PMCreateContactVCDelegate <NSObject>
-(void)didSaveContact:(DBSavedContact*)contact;
@end
@interface PMCreateContactVC : UIViewController
@property (nonatomic, strong) id<PMCreateContactVCDelegate> delegate;


@property (nonatomic, strong) NSDictionary *data;
@end
