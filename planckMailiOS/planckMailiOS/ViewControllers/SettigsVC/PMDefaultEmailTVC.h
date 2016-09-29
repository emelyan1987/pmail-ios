//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMDefaultEmailTVC;

@protocol PMDefaultEmailTVCDelegate <NSObject>

-(void)defaultEmailTVC:(PMDefaultEmailTVC*)defaultEmailTVC didSelectEmail:(NSString*)email;

@end

@interface PMDefaultEmailTVC : UITableViewController

@property(nonatomic, strong) id<PMDefaultEmailTVCDelegate>delegate;
@end
