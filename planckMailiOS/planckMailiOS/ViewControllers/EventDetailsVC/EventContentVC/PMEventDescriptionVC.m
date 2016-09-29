//
//  PMEventDescriptionVC.m
//  planckMailiOS
//
//  Created by LionStar on 2/6/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMEventDescriptionVC.h"
#import "Config.h"
@interface PMEventDescriptionVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PMEventDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBar];
    
    if(_event && _event.eventDescription && _event.eventDescription.length)
    {
        [self.webView loadHTMLString:DEFAULT_HTML_TEXT(_event.eventDescription) baseURL:nil];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    
    CGFloat width;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = size.height;
    }
    else {
        width = size.width;
    }
    width -= 120;
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = _event.title;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 0;
    lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    //float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    lblTitle.frame = CGRectMake(0, 0, width, 25);
    
    UILabel *lblCalendarTitle = [[UILabel alloc]init];
    [lblCalendarTitle setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    
    
    lblCalendarTitle.text = [_event getCalendar].name;
    lblCalendarTitle.textColor = [UIColor whiteColor];
    lblCalendarTitle.textAlignment = NSTextAlignmentCenter;
    lblCalendarTitle.numberOfLines = 0;
    lblCalendarTitle.lineBreakMode = NSLineBreakByWordWrapping;
    lblCalendarTitle.frame = CGRectMake(0, 26, width, 15);
    
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    
    [headerview addSubview:lblTitle];
    [headerview addSubview:lblCalendarTitle];
    
    self.navigationItem.titleView = headerview;
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
