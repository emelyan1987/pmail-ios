//
//  WKContactRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "WKContactRow.h"
@import UIKit;
@interface WKContactRow ()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;

@end

@implementation WKContactRow

- (void)setContactFirstName:(NSString *)firstName lastName:(NSString *)lastName {
  NSString *text = [NSString stringWithFormat:@"%@%@", [firstName length] > 0?[firstName stringByAppendingString:@" "]:@"", lastName];
  NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:text
                                                                            attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
  if([firstName length] > 0) {
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.f alpha:0.65] range:NSMakeRange(0, [firstName length])];
  }
  
  [_titleLabel setAttributedText:title];
}

- (void)setContactName:(NSString *)name
{
    [_titleLabel setText:name];
}

@end
