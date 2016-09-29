//
//  PMSFLeadsVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFLeadsVC.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "PMSFLeadTVCell.h"
#import "PMSFLeadDetailsVC.h"
#import "PMSFCreateLeadNC.h"
#import "UITableView+BackgroundText.h"
#import "Config.h"

#define RATING_FILTER_HOT @"Hot"
#define RATING_FILTER_WARM @"Warm"
#define RATING_FILTER_COLD @"Cold"
#define RATING_FILTER_NONE @"None"

typedef NS_ENUM(NSInteger, SelectedTab) {
    All = 0,
    Hot,
    Warm,
    Cold,
    None
};

@interface PMSFLeadsVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *tabBtnAll;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnHot;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnWarm;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnCold;
@property (weak, nonatomic) IBOutlet UIButton *tabBtnNone;
@property (weak, nonatomic) IBOutlet UIView *tabLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabLineLeadingConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UILabel *statusLabel;
@property (nonatomic, strong) NSMutableArray *items;

@property SelectedTab currentSelectedTab;

@property (nonatomic, strong) NSMutableDictionary *loadMoreFlags;
@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, assign) BOOL filtered;
@property (nonatomic, strong) NSMutableArray *filteredItems;
@property (nonatomic, strong) NSMutableDictionary *filterParams;

- (IBAction)actionAddBtnTap:(id)sender;
- (IBAction)tabBtnAllClicked:(id)sender;
- (IBAction)tabBtnHotClicked:(id)sender;
- (IBAction)tabBtnWarmClicked:(id)sender;
- (IBAction)tabBtnColdClicked:(id)sender;
- (IBAction)tabBtnNoneClicked:(id)sender;



@end

@implementation PMSFLeadsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    
    [_tableView showEmptyMessage:@"Please refresh list to see the leads"];
    _tableView.backgroundView.hidden = YES;
    [self loadData:0];
    
    _filteredItems = [NSMutableArray new];
    _filterParams = [NSMutableDictionary new];
    
    [self setNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationSalesforceTokenRefreshed:) name:NOTIFICATION_SALESFORCE_TOKEN_REFRESHED object:nil];
}
-(void)handleRefresh:(id)sender
{
    [self loadData:0];
    [_refreshControl endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    NSString *title = @"Leads";
    
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
-(void)loadData:(NSInteger)offset
{
    if(_items==nil) _items = [NSMutableArray new];
    if(offset==0) _loadMoreFlags = nil;
    
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Loading leads..." type:ACTIVITY_STATUS_TYPE_PROGRESS view:self.view time:issuedTime];
    [[PMAPIManager shared] getSalesforceLeads:offset completion:^(id data, id error, BOOL success) {
        [AlertManager hideStatusBar:issuedTime];
        if(success)
        {
            if(offset==0)
            {
                [_items removeAllObjects];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM dd, YYYY HH:mm a"];
                
                [_statusLabel setText:[NSString stringWithFormat:@"Last Synched %@", [dateFormatter stringFromDate:[NSDate date]]]];
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
        [_filterParams removeObjectForKey:@"Rating"];
    }
    else if (tab == Hot)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnHot.frame.origin.x;
        [_filterParams setObject:RATING_FILTER_HOT forKey:@"Rating"];
    }
    else if (tab == Warm)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnWarm.frame.origin.x;
        [_filterParams setObject:RATING_FILTER_WARM forKey:@"Rating"];
    }
    else if (tab == Cold)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnCold.frame.origin.x;
        [_filterParams setObject:RATING_FILTER_COLD forKey:@"Rating"];
    }
    else if (tab == None)
    {
        self.tabLineLeadingConstraint.constant = self.tabBtnNone.frame.origin.x;
        [_filterParams setObject:RATING_FILTER_NONE forKey:@"Rating"];
    }
    
    [UIView animateWithDuration:.2f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    _currentSelectedTab = tab;
    
    [self.tabBtnAll setTitleColor:_currentSelectedTab==All?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnHot setTitleColor:_currentSelectedTab==Hot?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnWarm setTitleColor:_currentSelectedTab==Warm?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnCold setTitleColor:_currentSelectedTab==Cold?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.tabBtnNone setTitleColor:_currentSelectedTab==None?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    
    [self.tabBtnAll.titleLabel setFont:_currentSelectedTab==All?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnHot.titleLabel setFont:_currentSelectedTab==Hot?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnWarm.titleLabel setFont:_currentSelectedTab==Warm?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnCold.titleLabel setFont:_currentSelectedTab==Cold?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.tabBtnNone.titleLabel setFont:_currentSelectedTab==None?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    
    
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
    
    PMSFLeadTVCell *cell = (PMSFLeadTVCell*)[tableView dequeueReusableCellWithIdentifier:@"sfLeadCell"];
    
    NSDictionary *item = _filtered?_filteredItems[indexPath.row] : _items[indexPath.row];
    
    [cell bindItem:item];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _filtered ? _filteredItems[indexPath.row] : _items[indexPath.row];
    
    PMSFLeadDetailsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFLeadDetailsVC"];
    
    vc.data = item;
    [self.navigationController pushViewController:vc animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveSuccess:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveFailure:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil];
    
    
    
    
}
- (IBAction)actionAddBtnTap:(id)sender
{
    
    PMSFCreateLeadNC *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFCreateLeadNC"];
    
    [self presentViewController:nc animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveSuccess:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveFailure:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil];
}

- (IBAction)tabBtnAllClicked:(id)sender {
    [self selectTab:All];
}

- (IBAction)tabBtnHotClicked:(id)sender {
    [self selectTab:Hot];
}

- (IBAction)tabBtnWarmClicked:(id)sender {
    [self selectTab:Warm];
}

- (IBAction)tabBtnColdClicked:(id)sender {
    [self selectTab:Cold];
}

- (IBAction)tabBtnNoneClicked:(id)sender {
    [self selectTab:None];
}



- (void)handleSalesforceLeadSaveSuccess:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Salesforce lead saved." type:ACTIVITY_STATUS_TYPE_INFO view:self.view time:nil];
    
    [self loadData:0];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceLeadSaveSuccess" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceLeadSaveFailure" object:nil];
}

- (void)handleSalesforceLeadSaveFailure:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Saving salesforce lead failed." type:ACTIVITY_STATUS_TYPE_ERROR view:self.view time:nil];
    
    
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceLeadSaveSuccess" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SalesforceLeadSaveFailure" object:nil];
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
    NSString *ratingToFilter = [_filterParams objectForKey:@"Rating"];
    
    if(!nameToFilter && !ratingToFilter)
    {
        _filtered = NO;
    }
    else
    {
        [_filteredItems removeAllObjects];
        
        NSMutableString *predicateString = [NSMutableString new];
        
        if(nameToFilter)
            [predicateString appendFormat:@"(Name contains[cd] '%@')", nameToFilter];
        if(ratingToFilter)
        {
            if(predicateString.length) [predicateString appendString:@" AND "];
            if([ratingToFilter isEqualToString:RATING_FILTER_HOT])
            {
                [predicateString appendFormat:@"Rating == 'Hot'"];
            }
            else if([ratingToFilter isEqualToString:RATING_FILTER_WARM])
            {
                [predicateString appendFormat:@"Rating == 'Warm'"];
            }
            else if([ratingToFilter isEqualToString:RATING_FILTER_COLD])
            {
                [predicateString appendFormat:@"Rating == 'Cold'"];
            }
            else if([ratingToFilter isEqualToString:RATING_FILTER_NONE])
            {
                [predicateString appendFormat:@"Rating == nil"];
            }
        }
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        
        _filteredItems = [NSMutableArray arrayWithArray:[_items filteredArrayUsingPredicate:predicate]];
        
        _filtered = YES;
    }
    [_tableView reloadData];
}
@end
