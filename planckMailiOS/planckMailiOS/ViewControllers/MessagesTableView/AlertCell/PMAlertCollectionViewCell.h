//
//  PMAlertCollectionViewCell.h
//  planckMailiOS
//
//  Created by nazar on 10/20/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMAlertCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroungView;

@end
