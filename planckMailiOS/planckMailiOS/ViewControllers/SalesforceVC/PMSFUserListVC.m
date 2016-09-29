//
//  PMSFUserListVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFUserListVC.h"
#import "PMAPIManager.h"
#import "AlertManager.h"

@interface PMSFUserListVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation PMSFUserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)loadData
{
    [[PMAPIManager shared] getSalesforceUsers:^(id data, id error, BOOL success) {
        if(success)
        {
            _items = data;
            [_tableView reloadData];
        }
    }];
    

}


#pragma UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sfUserCell"];
    
    NSDictionary *item = _items[indexPath.row];
    
    [cell.textLabel setText:item[@"Name"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _items[indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(userListVC:didSelectUser:)])
        [self.delegate userListVC:self didSelectUser:item];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
