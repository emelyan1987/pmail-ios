//
//  WKEmailRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailRow.h"
#import "NSDate+DateConverter.h"
#import "PMThread.h"

@interface WKEmailRow ()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *unreadIndicator;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *activityView;

@end

@implementation WKEmailRow

- (void)setEmailContainer:(PMThread *)emailContainer {
  [self.titleLabel setText:emailContainer.ownerName];
  [self.subjectLabel setText:emailContainer.subject];
  [self.dateLabel setText:[emailContainer.lastMessageDate convertedStringValue]];
    
  [self.unreadIndicator setHidden:!emailContainer.isUnread];
}

- (void)showActivityIndicator:(BOOL)yesOrNo {
    if (yesOrNo) {
        //unhide
        [self.activityView setHidden:NO];
        
        // Uses images in WatchKit app bundle.
        [self.activityView setImageNamed:@"frame-"];
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
        
        //hide
        [self.activityView setHidden:YES];
    }
}

@end
