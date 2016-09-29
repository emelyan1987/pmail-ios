//
//  PMEventAlertVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventAlertVC.h"

@interface PMEventAlertVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *_tableView;
    
    NSArray *_itemsArray;
}
@end

@implementation PMEventAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _itemsArray = @[@"None",
                    @"At time of event",
                    @"5 minutes before",
                    @"10 minutes before",
                    @"15 minutes before",
                    @"30 minutes before",
                    @"1 hour before",
                    @"2 hours before",
                    @"1 day before",
                    @"2 days before",
                    @"1 week before"
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
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"alertCell"];
    lCell.textLabel.text = _itemsArray[indexPath.row];
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

#pragma mark - TableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(PMEventAlertVCDelegate:alertTimeDidChange:message:)]) {
        [_delegate PMEventAlertVCDelegate:self alertTimeDidChange:nil message:_itemsArray[indexPath.row]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
