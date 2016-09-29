//
//  PMFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileListViewController.h"
#import <MBProgressHUD.h>

#import "KxMenu.h"

@interface PMFileListViewController ()
{
    NSString *_title;
    
    MBProgressHUD *HUD;
    UISearchBar *_searchBar;
    
    UIButton *_btnFilter;
}
@end

@implementation PMFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tblFileList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setNavigationBar:(NSString*)title
{
    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:backBtnItem];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"searchIcon.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(onSearch) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch sizeToFit];
    CGRect btnSearchFrame = btnSearch.frame;
    
    _btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_white"] forState:UIControlStateNormal];
    
    [_btnFilter addTarget:self action:@selector(onFilter) forControlEvents:UIControlEventTouchUpInside];
    [_btnFilter sizeToFit];
    CGRect btnFilterFrame = _btnFilter.frame;
    
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnSearchFrame.size.width+btnFilterFrame.size.width+4, btnSearchFrame.size.height)];
    
    
    [actionView addSubview:btnSearch];
    
    btnFilterFrame.origin.x = btnSearchFrame.size.width + 4;
    _btnFilter.frame = btnFilterFrame;
    
    [actionView addSubview:_btnFilter];
    
    
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:actionView] animated:YES];
    
    
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
    lblTitle.text = title;
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
    [self.navigationItem setHidesBackButton:NO];
    
    _title = title;
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onSearch
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setDelegate:self];
    [_searchBar setPlaceholder:@"Search"];
    [_searchBar setTintColor:[UIColor whiteColor]];
    [_searchBar setBarTintColor:[UIColor whiteColor]];
    [_searchBar setImage:[UIImage imageNamed:@"searchIcon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searhBarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
    [_searchBar setShowsCancelButton:YES];
    
    UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
    searchTextField.textColor = [UIColor whiteColor];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    [_searchBar setText:self.searchText];
    self.navigationItem.titleView = _searchBar;
    
    
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItems = nil;
    
    [_searchBar becomeFirstResponder];
}

#pragma UISearchBarDelegate Start
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setNavigationBar:_title];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self processSearch:searchBar.text];
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
    if (![text isEqualToString:@""]) {
        self.isFilter = YES;
    } else {
        self.isFilter = NO;
    }
}

- (void)onFilter
{
    CGRect btnRect = _btnFilter.frame;
    btnRect.origin.x += self.navigationItem.rightBarButtonItem.customView.frame.origin.x;
    btnRect.origin.y += btnRect.size.height;
    [self showFilterMenu:self.view fromRect:btnRect];
}
-(void)showFilterMenu:(UIView *)view fromRect:(CGRect)rect
{
    KxMenuItem *menuAll = [KxMenuItem menuItem:@"all"
                                         image:nil
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuImage = [KxMenuItem menuItem:@"images"
                                           image:[UIImage imageNamed:@"menu_image"]
                                          target:self
                                          action:@selector(pushFilterItem:)];
    KxMenuItem *menuDoc = [KxMenuItem menuItem:@"docs"
                                         image:[UIImage imageNamed:@"filter_doc_icon"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuPpt = [KxMenuItem menuItem:@"slides"
                                         image:[UIImage imageNamed:@"filter_ppt_icon"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuPdf = [KxMenuItem menuItem:@"pdfs"
                                         image:[UIImage imageNamed:@"filter_pdf_icon"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuZip = [KxMenuItem menuItem:@"zip files"
                                         image:[UIImage imageNamed:@"filter_zip_icon"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    
    NSArray *menuItems =
    @[menuAll, menuImage, menuDoc, menuPpt, menuPdf, menuZip];
    
    menuAll.foreColor = [UIColor darkGrayColor];
    menuAll.alignment = NSTextAlignmentCenter;
    
    menuImage.foreColor = [UIColor darkGrayColor];
    menuImage.alignment = NSTextAlignmentCenter;
    
    menuDoc.foreColor = [UIColor darkGrayColor];
    menuDoc.alignment = NSTextAlignmentCenter;
    
    menuPpt.foreColor = [UIColor darkGrayColor];
    menuPpt.alignment = NSTextAlignmentCenter;
    
    menuPdf.foreColor = [UIColor darkGrayColor];
    menuPdf.alignment = NSTextAlignmentCenter;
    
    menuZip.foreColor = [UIColor darkGrayColor];
    menuZip.alignment = NSTextAlignmentCenter;
    
    //[KxMenu setTintColor:[UIColor whiteColor]];
    
    
    [KxMenu showMenuInView:view
                  fromRect:rect
                 menuItems:menuItems];
}

- (void) pushFilterItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem*)sender;
    
    NSString *title = item.title;
    
    NSString *type;
    
    if([title isEqualToString:@"all"]) type = @"all";
    else if([title isEqualToString:@"images"]) type = @"image";
    else if([title isEqualToString:@"docs"]) type = @"doc";
    else if([title isEqualToString:@"slides"]) type = @"ppt";
    else if([title isEqualToString:@"pdfs"]) type = @"pdf";
    else if([title isEqualToString:@"zip files"]) type = @"zip";
    
    [self selectFilterMenu:type];
}

- (void)selectFilterMenu:(NSString *)type
{
    
    if([type isEqualToString:@"all"])
    {
        self.isFilter = NO;
        self.filterName = @"";
    }
    else
    {
        self.isFilter = YES;
        self.filterName = type;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 30;
    return 78;
}

-(void)showLoadingProgressBar
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
    HUD.labelText = @"Loading...";
    //HUD.dimBackground = YES;
    
    [HUD show:YES];
}
-(void)hideLoadingProgressBar
{
    [HUD hide:YES];
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
