//
//  PMGoogleDriveFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"
#import "GTLDrive.h"


@interface PMGoogleDriveFileListViewController : PMFileListViewController

@property GTLServiceDrive *service;
@property GTLDriveFile *folder;
@property NSString *folderID;
@end

