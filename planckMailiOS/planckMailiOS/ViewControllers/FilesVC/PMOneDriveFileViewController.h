//
//  PMOneDriveFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import <OneDriveSDK/OneDriveSDK.h>

@interface PMOneDriveFileViewController : PMFileViewController
@property (strong, nonatomic) ODClient *client;
@property (strong, nonatomic) ODItem *fileitem;

@end
