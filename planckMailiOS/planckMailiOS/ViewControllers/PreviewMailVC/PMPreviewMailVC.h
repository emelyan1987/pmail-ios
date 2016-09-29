//
//  PMPreviewMailVC.h
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "PMThread.h"
#import "UIViewController+PMStoryboard.h"

typedef enum {
    PMPreviewMailVCTypeActionArchive,
    PMPreviewMailVCTypeActionDelete,
    PMPreviewMailVCTypeActionMarkUnread,
    PMPreviewMailVCTypeActionMarkImportant,
    PMPreviewMailVCTypeActionMarkUnimportant,
    PMPreviewMailVCTypeActionUnsubscribe,
    PMPreviewMailVCTypeActionMove,
    PMPreviewMailVCTypeActionSnooze,
    PMPreviewMailVCTypeActionStarred,
    PMPreviewMailVCTypeActionMarkRead
} PMPreviewMailVCTypeAction;

@protocol PMPreviewMailVCDelegate <NSObject>
- (void)PMPreviewMailVCDelegateAction:(PMPreviewMailVCTypeAction)typeAction mail:(PMThread*)model;
@end

@interface PMPreviewMailVC : UIViewController
@property(nonatomic, strong) PMThread *inboxMailModel;
@property(nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, weak) id<PMPreviewMailVCDelegate> delegate;
@property(nonatomic, assign) selectedMessages selectedTableType;

@property(nonatomic, strong) NSArray *inboxMailArray;
@property(nonatomic, assign) NSInteger selectedMailIndex;

@property(nonatomic, assign) BOOL isRoot;
@end
