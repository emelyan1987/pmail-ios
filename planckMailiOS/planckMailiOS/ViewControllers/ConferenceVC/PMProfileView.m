//
//  PMProfileView.m
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMProfileView.h"

@implementation PMProfileView

+ (PMProfileView*)createView:(CGFloat)radius
{
    PMProfileView *lView = (PMProfileView*)[[[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil] lastObject];
    if ([lView isKindOfClass:[self class]]){
        lView.layer.cornerRadius = radius;
        lView.profileImageView.layer.cornerRadius = radius;
        lView.profileImageView.clipsToBounds = YES;
        return lView;
    } else {
        return nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
