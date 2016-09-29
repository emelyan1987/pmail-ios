//
//  PMGoogleDriveFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import "GTLDrive.h"


@interface PMGoogleDriveFileViewController : PMFileViewController

@property GTLServiceDrive *service;
@property GTLDriveFile *fileitem;

@end
