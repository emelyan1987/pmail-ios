//
//  PMMailMenuView.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+PMViewCreator.h"
#import "DBManager.h"

@protocol PMMailMenuViewDelegate <NSObject>
- (void)PMMailMenuViewSelectNamespace:(DBNamespace *)item;
@end

@interface PMMailMenuView : UIView
- (void)showInView:(UIView *)view;

@property(nonatomic, weak) id<PMMailMenuViewDelegate> delegate;
@end
