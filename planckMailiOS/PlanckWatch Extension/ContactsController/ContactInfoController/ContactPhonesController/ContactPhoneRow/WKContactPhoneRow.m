//
//  WKContactPhoneRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactPhoneRow.h"
#import <WatchKit/WatchKit.h>
#import "WatchKitDefines.h"

@interface WKContactPhoneRow ()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *phone;

@end

@implementation WKContactPhoneRow

- (void)setPhone:(NSString *)phone label:(NSString *)label {
  [_label setText:[label uppercaseString]];
  [_phone setText:phone];
}

@end
