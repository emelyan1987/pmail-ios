//
//  WKBaseController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/2/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WKBaseController : WKInterfaceController

- (void)showActivityIndicator:(BOOL)yesOrNo;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *activityView;

@end
