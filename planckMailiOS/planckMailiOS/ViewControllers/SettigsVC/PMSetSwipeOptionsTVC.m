//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSetSwipeOptionsTVC.h"

#import "PMSettingsManager.h"
#import "PMSwipeOptionSelectTVC.h"
#import "Config.h"


@interface PMSetSwipeOptionsTVC () <UITableViewDataSource, UITableViewDelegate, PMSwipeOptionSelectTVCDelegate>
{
    
    
}
@end

@implementation PMSetSwipeOptionsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Swipe Options";
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


#pragma UITableViewDataSource & UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 44;
    else return 100;
        
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//    return sectionTitle;
//}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section==0)
    {
        if(indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"swipeLeftCell"];
            cell.detailTextLabel.text = SWIPE_OPTIONS[[[PMSettingsManager instance] getLeftSwipeOption]];
        }
        else if(indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"swipeLeftImageCell"];
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"swipeRightCell"];
            cell.detailTextLabel.text = SWIPE_OPTIONS[[[PMSettingsManager instance] getRightSwipeOption]];
        }
        else if(indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"swipeRightImageCell"];
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMSwipeOptionSelectTVC *optionSelectTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSwipeOptionSelectTVC"];
    optionSelectTVC.delegate = self;
    if(indexPath.section == 0)
        optionSelectTVC.directionType = @"left";
    else
        optionSelectTVC.directionType = @"right";
    
    [self.navigationController pushViewController:optionSelectTVC animated:YES];
}

#pragma mark PMSwipeOptionSelectTVCDelegate
-(void)swipeOptionSelectTVC:(PMSwipeOptionSelectTVC *)tvc didSelectSwipeOption:(NSString *)option
{
    if([tvc.directionType isEqualToString:@"right"])
        [[PMSettingsManager instance] setRightSwipeOption:option];
    else
        [[PMSettingsManager instance] setLeftSwipeOption:option];
    
    if([self.delegate respondsToSelector:@selector(swipeOptionsTVC:didSetSwipeOptions:rightOption:)])
        [self.delegate swipeOptionsTVC:self didSetSwipeOptions:[[PMSettingsManager instance] getLeftSwipeOption] rightOption:[[PMSettingsManager instance] getRightSwipeOption]];
    
    [self.tableView reloadData];
}
@end
