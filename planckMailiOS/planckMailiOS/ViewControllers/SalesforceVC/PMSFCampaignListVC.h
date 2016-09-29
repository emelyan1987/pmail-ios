//
//  PMSFAccountListVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSFCampaignListVC;
@protocol PMSFCampaignListVCDelegate <NSObject>
-(void)campaignListVC:(PMSFCampaignListVC*)vc didSelectCampaign:(NSDictionary*)data;
@end
@interface PMSFCampaignListVC : UIViewController
@property (nonatomic, strong) id<PMSFCampaignListVCDelegate> delegate;
@end
