//
//  PMBoxFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"

#import <BoxContentSDK/BOXContentSDK.h>

@interface PMBoxFileListViewController : PMFileListViewController

//@property (weak, nonatomic) IBOutlet UITableView *tblFileList;



@property (nonatomic, readwrite, strong) BOXContentClient *client;
@property (nonatomic, readwrite, strong) NSString *folderID;

@property (nonatomic, strong) NSString *folderName;

@end
