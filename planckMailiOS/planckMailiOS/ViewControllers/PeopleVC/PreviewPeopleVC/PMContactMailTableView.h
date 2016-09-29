//
//  PMContactMailTableView.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"

@protocol PMContactMailTableViewDelegate <NSObject>
- (void)didSelectMessage:(NSDictionary*)message;
- (void)didSelectAttachment:(NSDictionary *)file;
@end

@interface PMContactMailTableView : UIView

+(instancetype)createWithModel:(PMContactModel*)model;

@property(nonatomic, strong) id<PMContactMailTableViewDelegate> delegate;

@property(nonatomic, strong) NSArray *messages;
@property(nonatomic, strong) PMContactModel *model;

@end
