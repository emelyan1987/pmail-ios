//
//  MainViewController.m
//  LGSideMenuControllerDemo
//
//  Created by Grigory Lutkov on 25.04.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "MainViewController.h"
#import "LeftViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "Config.h"
#import "Reachability.h"
#import "AlertManager.h"
#import "PMTabBarController.h"

@interface MainViewController ()

@property (strong, nonatomic) LeftViewController *leftViewController;

@property Reachability *nylasReach;
@property NSDate *networkStatusTime;
@end

@implementation MainViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableSwipe) name:@"disableSwipe" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSwipe) name:@"enableSwipe" object:nil];
    
    
    
//    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *lNamespacesArray = [[DBManager instance] getNamespaces];
    self.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    if (lNamespacesArray.count > 0) {
        PMTabBarController *lTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [(UINavigationController *)self.rootViewController setNavigationBarHidden:YES];
        [(UINavigationController*)self.rootViewController pushViewController:lTabController animated:NO];
        
        [AppDelegate sharedInstance].tabBarController = lTabController;
    }
    
    _leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];

    [self setLeftViewEnabledWithWidth:308.0f
                    presentationStyle:LGSideMenuPresentationStyleScaleFromBig
                 alwaysVisibleOptions:0];
    self.leftViewBackgroundColor = PM_TURQUOISE_COLOR;
    _leftViewController.tableView.backgroundColor = [UIColor clearColor];
     _leftViewController.view.backgroundColor = [UIColor clearColor];
    _leftViewController.tintColor = [UIColor whiteColor];
    [_leftViewController.tableView reloadData];
    [self.leftView addSubview:_leftViewController.view];
    self.rootViewLayerShadowRadius = 0;
    self.rootViewLayerShadowColor = [UIColor clearColor];
    self.rootViewLayerBorderColor = [UIColor clearColor];
    self.mainTitle.textColor = [UIColor whiteColor];
    self.mainTitle.text = @"PLANCK";
    
    
    
    
    // Network Reachiability Setting
    // ================= Connection Reachability Setting ================
    __weak __block typeof(self) weakself = self;
    
    
    _nylasReach = [Reachability reachabilityWithHostname:@"api.nylas.com"];
    //_nylasReach = [Reachability reachabilityWithHostname:@"54.215.245.106:5555"];
    
    _nylasReach.reachableBlock = ^(Reachability * reachability)
    {
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this uses NSOperationQueue mainQueue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(weakself.networkStatusTime)
            {
                [AlertManager hideStatusBar:weakself.networkStatusTime];
                weakself.networkStatusTime = nil;
            }
        }];
    };
    
    _nylasReach.unreachableBlock = ^(Reachability * reachability)
    {
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this one uses dispatch_async they do the same thing (as above)
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakself.networkStatusTime) return;
            weakself.networkStatusTime = [NSDate date];
            [AlertManager showStatusBarWithMessage:@"Connection is offline" type:ACTIVITY_STATUS_TYPE_ERROR time:weakself.networkStatusTime];
        });
    };
    
    [_nylasReach startNotifier];
    
}

-(void)disableSwipe {

    self.leftViewSwipeGestureEnabled = NO;
    
}

-(void)enableSwipe {

    self.leftViewSwipeGestureEnabled = YES;
    
}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    _leftViewController.view.frame = CGRectMake(0.f , 66.f, size.width, size.height);
}


@end
