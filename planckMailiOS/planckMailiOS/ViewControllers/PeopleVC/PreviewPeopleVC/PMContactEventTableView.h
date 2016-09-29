//
//  PMContactEventTableView.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"
#import "PMEventModel.h"

@protocol PMContactEventTableViewDelegate <NSObject>
- (void) didSelectEvent:(PMEventModel*)event index:(NSInteger)index;
- (void) didLoadEvents:(NSArray*)eventsArray;
@end
@interface PMContactEventTableView : UIView
+(instancetype)createWithModel:(PMContactModel*)model;
-(void)refreshData;
@property(nonatomic, strong) id<PMContactEventTableViewDelegate> delegate;
@property(nonatomic, strong) PMContactModel *model;
@property(nonatomic, strong) NSMutableArray *events;
@end
