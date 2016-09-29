//
//  PMMediaCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMMediaCell.h"

@interface PMMediaCell()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
@implementation PMMediaCell

-(void)setImage:(UIImage*)image
{
    self.imageView.image = image;
}
@end
