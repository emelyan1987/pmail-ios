//
//  UIImage+ImageSize.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/28/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageSize)

- (UIImage *)getScaledImage;
- (UIImage *)makeRoundedWithRadius: (float) radius;
- (UIImage *)roundCorners;

@end
