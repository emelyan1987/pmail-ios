//
//  WKBaseController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/2/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKBaseController.h"

@implementation WKBaseController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

-(void)showActivityIndicator:(BOOL)yesOrNo {
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
