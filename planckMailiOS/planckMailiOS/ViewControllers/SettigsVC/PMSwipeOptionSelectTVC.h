//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSwipeOptionSelectTVC;

@protocol PMSwipeOptionSelectTVCDelegate <NSObject>

-(void)swipeOptionSelectTVC:(PMSwipeOptionSelectTVC*)tvc didSelectSwipeOption:(NSString*)option;

@end

@interface PMSwipeOptionSelectTVC : UITableViewController

@property(nonatomic, strong) id<PMSwipeOptionSelectTVCDelegate>delegate;

@property(nonatomic, strong) NSString *directionType;
@end
