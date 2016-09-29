//
//  PMContactFileTableView.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"

@protocol PMContactFileTableViewDelegate <NSObject>
- (void) didSelectFile:(NSDictionary *)file;
@end

@interface PMContactFileTableView : UIView
+(instancetype)createWithModel:(PMContactModel*)model;
@property(nonatomic, strong) id<PMContactFileTableViewDelegate> delegate;
@property(nonatomic, strong) PMContactModel *model;
@property(nonatomic, strong) NSArray *files;


@end
