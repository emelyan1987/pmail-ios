//
//  PMTabBarController.m
//  planckMailiOS
//
//  Created by LionStar on 1/24/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMTabBarController.h"
#import "PMSettingsManager.h"
#import "Config.h"

@implementation PMTabBarController
-(void)viewDidLoad
{
    if(![[PMSettingsManager instance] getEnabledSalesforce])
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.viewControllers];
        [controllers removeObjectAtIndex:6];
        [controllers removeObjectAtIndex:6];
        [self setViewControllers:controllers animated:YES];
    }
    
    [[UITabBar appearance] setTintColor:PM_TURQUOISE_COLOR];
    
    // Get table view of more new viewController
    UITableView *view =(UITableView*)self.moreNavigationController.topViewController.view;
    
    view.tintColor = PM_TURQUOISE_COLOR; // Change the image color
    
    self.customizableViewControllers = nil;
}

- (void)updateUnreadsCount:(NSInteger)count
{
    if(count>0)
        self.viewControllers[0].tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", (int)count];
    else
        self.viewControllers[0].tabBarItem.badgeValue = nil;
}

@end
