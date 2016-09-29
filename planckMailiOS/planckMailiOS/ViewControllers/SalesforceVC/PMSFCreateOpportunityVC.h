//
//  PMSFCreateOpportunityVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/26/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMSFCreateOpportunityVCDelegate <NSObject>
-(void)didSaveWithData:(NSDictionary*)data;
@end

@interface PMSFCreateOpportunityVC : UIViewController
@property (nonatomic, strong) id<PMSFCreateOpportunityVCDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isView;
@end
