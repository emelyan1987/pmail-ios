//
//  PMButton.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMButton.h"

@implementation PMButton
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}
@end
