//
//  MediaViewController.h
//  Waffer
//
//  Created by Henry on 7/3/15.
//  Copyright (c) 2015 matko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>

@interface PMMediaViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) ALAssetsGroup *album;

@property (nonatomic, assign) BOOL isSelecting; // if is picking photo?
@end
