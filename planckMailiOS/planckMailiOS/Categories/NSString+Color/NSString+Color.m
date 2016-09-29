//
//  NSString.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSString+Color.h"

@implementation NSString(Color)

-(CGFloat)LabelColor
{
    
    int sum = 0;
    NSString *me = self;
    for (int i=0; i<me.length ; i++) {
        char c = [me characterAtIndex:i];
        
        sum += c;
    }
    
    
    double value = pow(sum, 3);
    
    return (CGFloat)(((int)value % 255)/255.0f);
}

-(UIColor*)color
{
    int sum = 0;
    NSString *me = self;
    for (int i=0; i<me.length ; i++) {
        char c = [me characterAtIndex:i];
        
        sum += c;
    }
    
    
    double value = pow(sum, 3);
    
    CGFloat colorValue = (CGFloat)(((int)value % 255)/255.0f);
    
    CGFloat hue = colorValue;//( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = 1.0;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = 0.8;//( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    return color;
}
@end
