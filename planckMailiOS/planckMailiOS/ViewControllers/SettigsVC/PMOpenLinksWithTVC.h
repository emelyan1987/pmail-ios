//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMOpenLinksWithTVC;

@protocol PMOpenLinksWithTVCDelegate <NSObject>

-(void)openLinksWithTVC:(PMOpenLinksWithTVC*)openLinksWithTVC didSelectBrowser:(NSString*)browserName;

@end

@interface PMOpenLinksWithTVC : UITableViewController

@property(nonatomic, strong) id<PMOpenLinksWithTVCDelegate>delegate;
@end
