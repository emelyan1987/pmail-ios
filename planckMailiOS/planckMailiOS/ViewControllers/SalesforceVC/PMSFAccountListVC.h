//
//  PMSFAccountListVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSFAccountListVC;
@protocol PMSFAccountListVCDelegate <NSObject>
-(void)accountListVC:(PMSFAccountListVC*)vc didSelectAccount:(NSDictionary*)accountData;
@end
@interface PMSFAccountListVC : UIViewController
@property (nonatomic, strong) id<PMSFAccountListVCDelegate> delegate;
@end
