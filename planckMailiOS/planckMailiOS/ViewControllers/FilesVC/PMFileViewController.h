//
//  PMFileViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMFileItem.h"
#import "PMFileManager.h"
#import "AlertManager.h"

#import "Global.h"

@interface PMFileViewController : UIViewController

@property BOOL isSelecting;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSString *backTitle;

@property NSString *filepath;
-(void) setNavigationBar:(NSString*)title;
-(void)showPreviewFile:(NSString*)filepath;
@end
