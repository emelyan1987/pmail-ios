//
//  PMFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewController.h"
#import "PMMailComposeVC.h"

@interface PMFileViewController () <UIWebViewDelegate>

@end

@implementation PMFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationBar:@""];
    
    if(_isSelecting) {
        [_btnAction setImage:[UIImage imageNamed:@"attachIcon"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setNavigationBar:(NSString*)title
{
    /*UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
     [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
     
     doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"DONE"  style:UIBarButtonItemStylePlain target:self action:@selector(onDone)];
     [self.navigationItem setRightBarButtonItem:doneBtn];*/
    /*UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Log out"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:nil];
    
    [self.navigationItem setBackBarButtonItem:btnItemBack];*/
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"MuseoSans-100" size:18.0f]];
    lblTitle.text = title;
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}


-(void)showPreviewFile:(NSString*)filepath
{
    self.filepath = filepath;
    
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        
    [_webView loadRequest:request];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"File open error: %@", error);
    
    NSString *extension = [[self.filepath pathExtension] lowercaseString];
    
    if([extension isEqualToString:@"mov"] || [extension isEqualToString:@"avi"] || [extension isEqualToString:@"mpg"]) return;
    
    NSString *iconFile = [PMFileManager IconFileByExt:extension];
    UIImage *image = [UIImage imageNamed:iconFile];
    
    _imageView.image = image;
    _imageView.hidden = NO;
}
- (IBAction)btnActionClicked:(id)sender {
    
    if(self.filepath&&self.filepath.length)
    {        
        if(self.isSelecting)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                NSDictionary *userInfo = @{@"filepath":self.filepath};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DoneSelectFile" object:nil userInfo:userInfo];
            }];
        }
        else
        {
            PMMailComposeVC *mailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
            
            NSMutableArray *files = [[NSMutableArray alloc] init];
            [files addObject:self.filepath];
            mailComposeVC.files = files;
            
            [self presentViewController:mailComposeVC animated:YES completion:nil];
        }
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
