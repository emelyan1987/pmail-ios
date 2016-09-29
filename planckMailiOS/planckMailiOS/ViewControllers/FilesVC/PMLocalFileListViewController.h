//
//  PMLocalFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"

@interface PMLocalFileListViewController : PMFileListViewController

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *absolutePath;
@end
