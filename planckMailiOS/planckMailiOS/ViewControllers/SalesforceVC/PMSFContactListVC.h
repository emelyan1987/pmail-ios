//
//  PMSFContactListVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSFContactListVC;
@protocol PMSFContactListVCDelegate <NSObject>
-(void)contactListVC:(PMSFContactListVC*)vc didSelectContact:(NSDictionary*)contactData;
@end

@interface PMSFContactListVC : UIViewController

@property (nonatomic, strong) id<PMSFContactListVCDelegate> delegate;
@end
