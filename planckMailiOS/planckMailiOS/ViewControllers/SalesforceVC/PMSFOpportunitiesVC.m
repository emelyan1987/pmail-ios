//
//  PMSFLeadsVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFOpportunitiesVC.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "PMSFOpportunityTVCell.h"
#import "PMSFCreateOpportunityNC.h"
#import "PMSFOpportunityDetailsVC.h"
#import "UITableView+BackgroundText.h"
#import "Config.h"
#import "PMSettingsManager.h"

#define STAGE_FILTER_OPEN @"open"
#define STAGE_FILTER_CLOSED @"closed"

typedef NS_ENUM(NSInteger, SelectedTab) {
    All = 0,
    Open,
    Closed
};

@interface PMSFOpportunitiesVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnAll;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnOpen;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnClosed;
@property (weak, nonatomic) IBOutlet UIView *tabLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabLineLeadingConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property SelectedTab currentSelectedTab;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableDictionary *loadMoreFlags;


@property (nonatomic, assign) BOOL filtered;
@property (nonatomic, strong) NSMutableArray *filteredItems;
@property (nonatomic, strong) NSMutableDictionary *filterParams;


@property (nonatomic, strong) NSLocale *locale;
- (IBAction)actionAddBtnTap:(id)sender;
- (IBAction)tabBtnAllClicked:(id)sender;
- (IBAction)tabBtnOpenClicked:(id)sender;
- (IBAction)tabBtnClosedClicked:(id)sender;

@end

@implementation PMSFOpportunitiesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    [_tableView showEmptyMessage:@"Please refresh list to see the opportunities"];
    _tableView.backgroundView.hidden = YES;
    
    [self loadData:0];
    
    _filteredItems = [NSMutableArray new];
    _filterParams = [NSMutableDictionary new];
    
    _locale = [NSLocale currentLocale];
    
    NSDictionary *organization = [[PMSettingsManager instance] getSalesforceOrganization];
    if(organization && organization[@"DefaultLocaleSidKey"])
    {
        _locale = [[NSLocale alloc] initWithLocaleIdentifier:organization[@"DefaultLocaleSidKey"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationSalesforceTokenRefreshed:) name:NOTIFICATION_SALESFORCE_TOKEN_REFRESHED object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    NSString *title = @"Opportunities";
    
    CGFloat width;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = size.height;
    }
    else {
        width = size.width;
    }
    width -= 168;
    
    UILabel *lblTitle = [[UILabel alloc]init];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [lblTitle setFont:font];
    lblTitle.text = title;
    lblTitle.textColor = PM_WHITE_COLOR;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 1;
    lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    lblTitle.frame = CGRectMake(0, 0, width, 25);
    
    _statusLabel = [[UILabel alloc]init];
    [_statusLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.numberOfLines = 1;
    _statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _statusLabel.frame = CGRectMake(0, 26, width, 15);
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    
    [headerview addSubview:lblTitle];
    [headerview addSubview:_statusLabel];
    
    self.navigationItem.titleView = headerview;
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)handleNotificationSalesforceTokenRefreshed:(NSNotification*)notification
{
    [self loadData:0];
}
-(void)handleRefresh:(id)sender
{
    [self loadData:0];
    [_refreshControl endRefreshing];
}
-(void)loadData:(NSInteger)offset
{
    if(_items==nil) _items = [NSMutableArray new];
    if(offset==0) _loadMoreFlags = nil;
    
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Loading opportunities..." type:ACTIVITY_STATUS_TYPE_PROGRESS view:self.view time:issuedTime];
    [[PMAPIManager shared] getSalesforceOpportunities:offset completion:^(id data, id error, BOOL success) {
        [AlertManager hideStatusBar:issuedTime];
        if(success)
        {
            if(offset==0)
            {
                [_items removeAllObjects];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM dd, YYYY HH:mm a"];
                
                [self.statusLabel setText:[NSString stringWithFormat:@"Last Synched %@", [dateFormatter stringFromDate:[NSDate date]]]];
            }
            [_items addObjectsFromArray:data];
            [_tableView reloadData];
            
            
            _offset = offset + 50;
            _tableView.backgroundView.hidden = YES;
        }
        else
        {
            _tableView.backgroundView.hidden = NO;
        }
    }];
}
- (void)selectTab:(SelectedTab)tab
{
    if (tab == All)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnAll.frame.origin.x;
        [_filterParams removeObjectForKey:@"StageName"];
    }
    else if (tab == Open)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnOpen.frame.origin.x;
        [_filterParams setObject:STAGE_FILTER_OPEN forKey:@"StageName"];
    }
    else if (tab == Closed)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnClosed.frame.origin.x;
        [_filterParams setObject:STAGE_FILTER_CLOSED forKey:@"StageName"];
    }
    
    [UIView animateWithDuration:.2f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    _currentSelectedTab = tab;
    
    [self.tabBtnAll setTitleColor:_currentSelectedTab==All?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnOpen setTitleColor:_currentSelectedTab==Open?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnClosed setTitleColor:_currentSelectedTab==Closed?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    
    [self.tabBtnAll.titleLabel setFont:_currentSelectedTab==All?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnOpen.titleLabel setFont:_currentSelectedTab==Open?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnClosed.titleLabel setFont:_currentSelectedTab==Closed?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    
    
    [self processFilter];
    
}

#pragma UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filtered ? _filteredItems.count : _items.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_filtered)
    {
        NSInteger itemIndex = indexPath.item;
        
        if(itemIndex == _items.count-1)
        {
            if(_loadMoreFlags==nil) _loadMoreFlags = [[NSMutableDictionary alloc] init];
            
            BOOL loadMoreFlag = [_loadMoreFlags objectForKey:@(itemIndex)];
            if(!loadMoreFlag)
            {
                [self loadData:_offset];
                [_loadMoreFlags setObject:[NSNumber numberWithBool:YES] forKey:@(itemIndex)];
            }
        }
    }
    
    
    PMSFOpportunityTVCell *cell = (PMSFOpportunityTVCell*)[tableView dequeueReusableCellWithIdentifier:@"sfOpportunityCell"];
    
    NSDictionary *item = _filtered?_filteredItems[indexPath.row] : _items[indexPath.row];
    
    [cell bindItem:item locale:_locale];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _filtered ? _filteredItems[indexPath.row] : _items[indexPath.row];
    
    PMSFOpportunityDetailsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFOpportunityDetailsVC"];
    
    vc.data = item;
    [self.navigationController pushViewController:vc animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveSuccess:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveFailure:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil];
    
}

- (IBAction)actionAddBtnTap:(id)sender
{
    PMSFCreateOpportunityNC *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFCreateOpportunityNC"];
    
    [self presentViewController:nc animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveSuccess:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveFailure:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil];
}

- (IBAction)tabBtnAllClicked:(id)sender {
    [self selectTab:All];
}

- (IBAction)tabBtnOpenClicked:(id)sender {
    [self selectTab:Open];
}

- (IBAction)tabBtnClosedClicked:(id)sender {
    [self selectTab:Closed];
}

#pragma mark SalesforceOpportunitySave Notification Handler
- (void)handleSalesforceOpportunitySaveSuccess:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Salesforce opportunity saved." type:ACTIVITY_STATUS_TYPE_INFO view:self.view time:nil];
    
    [self loadData:0];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceOpportunitySaveSuccess" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceOpportunitySaveFailure" object:nil];
}

- (void)handleSalesforceOpportunitySaveFailure:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Saving salesforce opportunity failed." type:ACTIVITY_STATUS_TYPE_ERROR view:self.view time:nil];
    
    
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceOpportunitySaveSuccess" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceOpportunitySaveFailure" object:nil];
}


#pragma mark - SearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self processSearch:searchText];    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self processSearch:searchBar.text];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:NO];
    return YES;
}

- (void)processSearch:(NSString*)text {
    
    if(text.length)
        [_filterParams setObject:text forKey:@"Name"];
    else
        [_filterParams removeObjectForKey:@"Name"];
    
    [self processFilter];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
    
    [_filterParams removeObjectForKey:@"Name"];
    
    [self processFilter];
}

- (void) processFilter
{
    NSString *nameToFilter = [_filterParams objectForKey:@"Name"];
    NSString *stageToFilter = [_filterParams objectForKey:@"StageName"];
    
    if(!nameToFilter && !stageToFilter)
    {
        _filtered = NO;
    }
    else
    {
        [_filteredItems removeAllObjects];
        
        NSMutableString *predicateString = [NSMutableString new];
        
        if(nameToFilter)
            [predicateString appendFormat:@"(Name contains[cd] '%@')", nameToFilter];
        if(stageToFilter)
        {
            if(predicateString.length) [predicateString appendString:@" AND "];
            if([stageToFilter isEqualToString:STAGE_FILTER_OPEN])
            {
                [predicateString appendFormat:@"IsClosed != 1"];
            }
            else if([stageToFilter isEqualToString:STAGE_FILTER_CLOSED])
            {
                [predicateString appendFormat:@"IsClosed == 1"];
            }
        }
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        
        _filteredItems = [NSMutableArray arrayWithArray:[_items filteredArrayUsingPredicate:predicate]];
        
        _filtered = YES;
    }
    [_tableView reloadData];
}
@end
