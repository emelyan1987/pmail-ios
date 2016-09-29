//
//  PMView.m
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMView.h"

@implementation PMView

-(void)setCornerRadius:(CGFloat)cornerRadius {

    _cornerRadius = cornerRadius;
    
    self.layer.cornerRadius = cornerRadius;
}

-(void)setBorderWidth:(CGFloat)borderWidth {

    _borderWidth = borderWidth;
    
    self.layer.borderWidth = borderWidth;
}

-(void)setBorderColor:(UIColor *)borderColor {

    _borderColor = borderColor;
    
    self.layer.borderColor = borderColor.CGColor;    
}

@end
