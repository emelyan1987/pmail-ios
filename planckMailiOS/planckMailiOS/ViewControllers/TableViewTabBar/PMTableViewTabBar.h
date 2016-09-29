//
//  PMTableViewTabBar.h
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMTableViewTabBarDelegate <NSObject>
@optional
- (void)messagesDidSelect:(selectedMessages)messages;
- (void)didPressedFilterBtn:(id)sender;
@end

@interface PMTableViewTabBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *importantMessagesBtn;
@property (weak, nonatomic) IBOutlet UIButton *socialMessagesBtn;
@property (weak, nonatomic) IBOutlet UIButton *readLaterMessageBtn;
@property (weak, nonatomic) IBOutlet UIButton *followUpsMessagesBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantUnreads;
@property (weak, nonatomic) IBOutlet UILabel *lblSocialUnreads;
@property (weak, nonatomic) IBOutlet UILabel *lblClutterUnreads;
@property (weak, nonatomic) IBOutlet UILabel *lblReminderUnreads;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *tabView;

- (void)selectMessages:(selectedMessages)messages animated:(BOOL)animated;
- (void)setShow:(BOOL)bShow;
- (void)updateUnreadCount:(NSDictionary*)countData;

- (IBAction)importantBtnTaped:(id)sender;
- (IBAction)socialBtnTaped:(id)sender;
- (IBAction)readLaterBtnTaped:(id)sender;
- (IBAction)followUpsBtnTapped:(id)sender;



@property (nonatomic, readonly) selectedMessages currectMessages;
@property (nonatomic, assign)id <PMTableViewTabBarDelegate> delegate;



@end
