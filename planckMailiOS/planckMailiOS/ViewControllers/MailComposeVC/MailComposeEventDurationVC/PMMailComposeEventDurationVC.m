//
//  PMEventAlertVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeEventDurationVC.h"

@interface PMMailComposeEventDurationVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *_tableView;
    
    NSArray *_itemsArray;
}
@end

@implementation PMMailComposeEventDurationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _itemsArray = @[
                    @"30 minutes",
                    @"1 hour",
                    @"2 hours",
                    @"3 hours",
                    @"4 hours",
                    @"5 hours",
                    @"6 hours"
                    ];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self setNavigationBar];
}

- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Select AlertTime";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"durationCell"];
    lCell.textLabel.text = _itemsArray[indexPath.row];
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

#pragma mark - TableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger duration = 30;
    
    switch (indexPath.row) {
        case 0:
            duration = 30;
            break;
        case 1:
            duration = 60;
            break;
        case 2:
            duration = 120;
            break;
        case 3:
            duration = 180;
            break;
        case 4:
            duration = 240;
            break;
        case 5:
            duration = 300;
            break;
        case 6:
            duration = 360;
            break;
            
        default:
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(eventDurationVC:didSelectDuration:)]) {
        [_delegate eventDurationVC:self didSelectDuration:duration];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
