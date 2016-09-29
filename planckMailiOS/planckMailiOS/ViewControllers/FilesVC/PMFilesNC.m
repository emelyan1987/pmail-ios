//
//  PMFilesNC.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/2/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFilesNC.h"
#import "PMFilesVC.h"

@interface PMFilesNC ()

@end

@implementation PMFilesNC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isSelecting = self.isSelecting;
    
    int i=0;
    i++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ((PMFilesVC*)segue.destinationViewController).isSelecting = self.isSelecting;
}


@end
