//
//  PMPhotoManager.h
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <AssetsLibrary/AssetsLibrary.h>


#define ASSET_PHOTO_THUMBNAIL           0
#define ASSET_PHOTO_SCREEN_SIZE         1
#define ASSET_PHOTO_FULL_RESOLUTION     2

@interface PMPhotoManager : NSObject
+ (ALAssetsLibrary *)defaultAssetsLibrary;
+ (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType;
+ (UIImage*)squareImageFromImage:(UIImage*)image scaledToSize:(CGFloat)newSize;
@end
