//
//  PMDropboxFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface PMDropboxFileViewController : PMFileViewController <DBRestClientDelegate>

@property(nonatomic, strong) DBRestClient *restClient;
@property(nonatomic, strong) DBMetadata *fileitem;
@end
