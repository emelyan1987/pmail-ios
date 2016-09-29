//
//  UIImage+ImageSize.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/28/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "UIImage+ImageSize.h"

@implementation UIImage (ImageSize)

#pragma mark - Public methods

- (UIImage *)getScaledImage {
    
    CGFloat lBigestSide = MAX(self.size.width, self.size.height);
    
    if (lBigestSide > 50) {
        
        CGFloat lCoeffitient = 50.0/lBigestSide;
        
        CGSize lNewSize = CGSizeMake(roundf(self.size.width*lCoeffitient), roundf(self.size.height*lCoeffitient));
        
        UIGraphicsBeginImageContextWithOptions(lNewSize, NO, 1.0);
        
        [self drawInRect:CGRectMake(0, 0, lNewSize.width, lNewSize.height)];
        
        UIImage *lNewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return lNewImage;
        
    }else{
        return self;
    }
}

-(UIImage *)makeRoundedWithRadius: (float) radius
{
    CALayer *imageLayer = [CALayer layer];
    CGFloat minSize = MIN(self.size.width, self.size.height);
    imageLayer.frame = CGRectMake(0, 0, minSize, minSize);
    imageLayer.contents = (id) self.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(self.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (UIImage *)roundCorners;
{
    int w = self.size.width;
    int h = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    addRoundedRectToPath(context, rect, w/2.f, h/2.f);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:imageMasked];    
}

#pragma mark - Private methods

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end
