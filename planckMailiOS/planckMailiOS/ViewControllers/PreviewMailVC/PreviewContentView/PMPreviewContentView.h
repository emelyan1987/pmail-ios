//
//  PMPreviewContentView.h
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+PMViewCreator.h"

@protocol PMPreviewContentViewDelegate <NSObject>
- (void)didSelectAttachment:(NSDictionary *)file;
-(void)didLoadContent;
@end

@interface PMPreviewContentView : UIView
@property(nonatomic, weak) id<PMPreviewContentViewDelegate> delegate;

- (void)showDetail:(NSString*)dataDetail files:(NSArray*)files messageId:(NSString*)mid haveToSummarize:(BOOL)haveToSummarize;

- (NSInteger)contentHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewRSVPHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblFileListHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWebViewHeightConstraint;

@property (nonatomic, copy) void (^btnRSVPTapAction)(id sender);
@end
