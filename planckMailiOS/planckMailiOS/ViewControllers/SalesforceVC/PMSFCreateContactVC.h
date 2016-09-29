//
//  PMSFCreateContactVC.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSFCreateContactVC;

@protocol PMSFCreateContactVCDelegate <NSObject>

-(void)sfCreateContactVC:(PMSFCreateContactVC*)sfCreateContactVC didSaveContactData:(NSDictionary*)data;

@end

@interface PMSFCreateContactVC : UIViewController
@property (nonatomic, strong) id<PMSFCreateContactVCDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, assign) BOOL isUpdate;
@end
