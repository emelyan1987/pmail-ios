//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PMSetSwipeOptionsTVC;

@protocol PMSetSwipeOptionsTVCDelegate <NSObject>

-(void)swipeOptionsTVC:(PMSetSwipeOptionsTVC*)tvc didSetSwipeOptions:(NSString*)leftOption rightOption:(NSString*)rightOption;

@end

@interface PMSetSwipeOptionsTVC : UITableViewController

@property(nonatomic, strong) id<PMSetSwipeOptionsTVCDelegate> delegate;
@end
