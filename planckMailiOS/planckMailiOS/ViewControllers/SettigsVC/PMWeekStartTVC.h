//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMWeekStartTVC;

@protocol PMWeekStartTVCDelegate <NSObject>

-(void)weekStartTVC:(PMWeekStartTVC*)weekStartTVC didSelectWeekStart:(NSString*)weekStart;

@end

@interface PMWeekStartTVC : UITableViewController

@property(nonatomic, strong) id<PMWeekStartTVCDelegate>delegate;
@end
