//
//  PMOneDriveFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"
#import <OneDriveSDK/OneDriveSDK.h>

@interface PMOneDriveFileListViewController : PMFileListViewController

@property (strong, nonatomic) ODClient *client;
@property (strong, nonatomic) ODItem *folder;
@end
