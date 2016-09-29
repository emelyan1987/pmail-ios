//
//  PMContactInfoTableView.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSavedContact.h"

@class PMContactInfoTableView;

@protocol PMContactInfoTableViewDelegate <NSObject>
- (void)composeMail:(NSDictionary*)data;
- (void)callPhone:(NSString*)phoneNumber;
- (void)sendSMS:(NSString*)phoneNumber;
@end
@interface PMContactInfoTableView : UIView

@property (nonatomic, copy) void (^btnEditTapAction)(id sender);


@property(nonatomic, strong) id<PMContactInfoTableViewDelegate> delegate;
@property(nonatomic, strong) NSDictionary *contactData;
@end
