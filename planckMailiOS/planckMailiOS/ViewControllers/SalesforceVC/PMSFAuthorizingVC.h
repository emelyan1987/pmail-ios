//
//  PMSFAuthorizingVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/20/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//


#import <SalesforceSDKCore/SFAuthorizingViewController.h>

@protocol PMSFAuthorizingVCDelegate <NSObject>
-(void)didSuccessAuthorizing:(NSDictionary*)authorizedData;
-(void)didFailureAuthorizing;
@end

@interface PMSFAuthorizingVC : SFAuthorizingViewController
@property(nonatomic, strong) id<PMSFAuthorizingVCDelegate> delegate;
@end
