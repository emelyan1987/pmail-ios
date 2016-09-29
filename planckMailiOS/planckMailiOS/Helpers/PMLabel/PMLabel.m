//
//  PMLabel.m
//  planckMailiOS
//
//  Created by LionStar on 3/31/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMLabel.h"
#define PADDING 5

@implementation PMLabel
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, PADDING, 0, PADDING};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
    
}
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = CGRectInset([self.attributedText boundingRectWithSize:CGSizeMake(999, 999)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                context:nil], -PADDING, 0);
    
    return rect;
}

//- (CGSize) intrinsicContentSize {
//    CGSize intrinsicSuperViewContentSize = [super intrinsicContentSize] ;
//    intrinsicSuperViewContentSize.width += PADDING * 2 ;
//    return intrinsicSuperViewContentSize ;
//}


@end
