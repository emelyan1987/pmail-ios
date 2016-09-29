//
//  PMMenuHeaderView.h
//  planckMailiOS
//
//  Created by admin on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBNamespace.h"

@class PMMenuHeaderView;
@protocol PMMenuHeaderViewDelegate <NSObject>
- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView selectedState:(BOOL)selected;
- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView expanded:(BOOL)expanded;
@end

@interface PMMenuHeaderView : UIView
@property(nonatomic, copy) NSString *titleName;
@property(nonatomic) BOOL selected;
@property(nonatomic) BOOL expanded;
@property(nonatomic, weak) id<PMMenuHeaderViewDelegate> delegate;


-(void)setTitle:(NSString *)title forProvider:(NSString*)provider;
-(void)expand;
-(void)collapse;
@end
