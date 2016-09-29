//
//  PMEventDetailsVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@class PMEventDetailsVC;


@interface PMEventDetailsVC : UIViewController
- (instancetype)initWithEvents:(NSArray *)events index:(NSUInteger)index;
@end
