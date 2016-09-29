//
//  PMBoxFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import <evernote-cloud-sdk-ios/ENSDKAdvanced.h>

@interface PMEvernoteNoteViewController : UIViewController

@property BOOL isSelecting;
@property (nonatomic, strong) ENNoteRef * noteRef;
@property (nonatomic, strong) NSString * noteTitle;
@end
