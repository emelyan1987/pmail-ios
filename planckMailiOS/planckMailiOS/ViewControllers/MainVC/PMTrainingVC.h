//
//  PMTrainingVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMTrainingVC : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (strong, nonatomic) IBOutlet UIView *pageView1;
@property (strong, nonatomic) IBOutlet UIView *pageView2;
@property (strong, nonatomic) IBOutlet UIView *pageView3;
@property (strong, nonatomic) IBOutlet UIView *pageView4;
@property (strong, nonatomic) IBOutlet UIView *pageView5;
@property (strong, nonatomic) IBOutlet UIWebView *webView1;
@property (strong, nonatomic) IBOutlet UIWebView *webView2;
@property (strong, nonatomic) IBOutlet UIWebView *webView3;
@property (strong, nonatomic) IBOutlet UIWebView *webView4;
@property (strong, nonatomic) IBOutlet UIWebView *webView5;
@end
