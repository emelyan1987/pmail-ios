//
//  PMMainVC.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMainVC.h"
#import "PMLoginVC.h"
#import "PMTrainingVC.h"

@interface PMMainVC () <UIGestureRecognizerDelegate, PMLoginVCDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnAddAccount;
@end

@implementation PMMainVC

#pragma mark - PMMainVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnAddAccount.layer.cornerRadius = 8;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PMLoginVC *lLoginVC = [segue destinationViewController];
    [lLoginVC setDelegate:self];
}

#pragma mark - LoginVC delegate

- (void)PMLoginVCDelegate:(PMLoginVC *)loginVC didSuccessLogin:(BOOL)state additionalAccount:(BOOL)additionalAccount {
    if (state && !additionalAccount) {
        
        PMTrainingVC *trainingVC = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"PMTrainingVC"];
        
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:trainingVC animated:YES];
    }
}

@end
