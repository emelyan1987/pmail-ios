//
//  PMBoxFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>

@interface PMBoxFileViewController : PMFileViewController

@property (nonatomic, readwrite, strong) NSString *itemID;
@property (nonatomic, readwrite, strong) BOXItem *fileitem;
@property (nonatomic ,readwrite, strong) BOXAPIItemType *itemType;
@property (nonatomic, readwrite, strong) BOXContentClient *client;

@end
