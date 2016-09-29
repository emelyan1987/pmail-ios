//
//  PMProfileView.h
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMProfileView : UIView

+(PMProfileView*)createView:(CGFloat)radius;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@end
