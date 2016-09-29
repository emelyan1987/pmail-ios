//
//  PMDropBoxFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface PMDropboxFileListViewController : PMFileListViewController <DBRestClientDelegate>
{
    NSMutableArray *arrayFiles;
    NSMutableArray *arrayFolders;
    NSMutableArray *arrayThumbnails;
    
    NSMutableArray *filteredFiles;
    NSMutableArray *filteredThumbnails;
    DBRestClient *restClient;
}



@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSString *loadData;

@end
