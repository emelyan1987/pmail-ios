//
//  UITableView+BackgroundText.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/4/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "UICollectionView+BackgroundText.h"

#import "Config.h"

@implementation UICollectionView (BackgroundText)

- (void)showEmptyMessage:(NSString *)message {

    UILabel *emptyMessageLabel;
    CGRect tableFrame = self.frame;
    emptyMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableFrame.origin.x + 20, tableFrame.origin.y, tableFrame.size.width - 40, tableFrame.size.height)];
    emptyMessageLabel.font = [UIFont boldSystemFontOfSize:18];
    emptyMessageLabel.numberOfLines = 2;
    emptyMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyMessageLabel.shadowColor = [UIColor lightTextColor];
    emptyMessageLabel.textColor = PM_TURQUOISE_COLOR;
    emptyMessageLabel.shadowOffset = CGSizeMake(0, 1);
    emptyMessageLabel.backgroundColor = [UIColor clearColor];
    emptyMessageLabel.textAlignment =  NSTextAlignmentCenter;
    
    //Here is the text for when there are no results
    emptyMessageLabel.text = message;
    
    self.backgroundView = emptyMessageLabel;
}

@end
