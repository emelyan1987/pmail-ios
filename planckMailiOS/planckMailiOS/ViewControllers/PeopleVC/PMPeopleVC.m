//
//  PMPeopleVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPeopleVC.h"
#import "PMPreviewPeopleVC.h"
#import "PMAPIManager.h"

#import "PMContactCell.h"
#import "AlertManager.h"

#import "CLContactLibrary.h"

#import "AlertManager.h"
#import "DBSavedContact.h"
#import "PMCreateContactVC.h"
#import "NSString+Utils.h"
#import "PMSettingsManager.h"

#import "Config.h"


#define CELL_IDENTIFIER @"contactCell"

#define LETTERS @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];

typedef NS_ENUM(NSInteger, SelectedTab) {
    All = 0,
    Phone,
    Email,
    Salesforce
};


@interface PMPeopleVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    NSMutableArray *_firstLettersArray;
    NSMutableDictionary *_itemsArray;
    NSMutableArray *_itemsArrayFiltered;
    
    NSArray *nylasContacts;
    NSArray *phoneContacts;
    
    NSMutableArray *contacts;
    NSMutableArray *filteredContacts;
    
    BOOL filtered;
    
    NSDate *phoneContactLoadingIssuedTime;
    
    SelectedTab currentSelectedTab;
    
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *btnTabAll;
@property (weak, nonatomic) IBOutlet UIButton *btnTabPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnTabEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnTabSalesforce;
@property (weak, nonatomic) IBOutlet UIView *viewTabLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTabLineLeadingConstraint;

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@property (nonatomic, strong) UIRefreshControl *refreshControl;
- (IBAction)btnTabAllClicked:(id)sender;
- (IBAction)btnTabPhoneClicked:(id)sender;
- (IBAction)btnTabEmailClicked:(id)sender;
- (IBAction)btnTabSalesforceClicked:(id)sender;
@end

@implementation PMPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsArray = [NSMutableDictionary new];
    _itemsArrayFiltered = [NSMutableArray new];
    _firstLettersArray = [NSMutableArray new];
    
    
    //self.navigationController.title = @"All Contacts";
    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [_searchBar setDelegate:self];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    
    [self.btnTabSalesforce setEnabled:[[PMSettingsManager instance] getEnabledSalesforce]];
    
    contacts = [NSMutableArray new];
    
    [self loadSavedContacts:_contactType];
    
    // if the app runs intially set contacts from phone
//    if(![[PMSettingsManager instance] getPhoneContactsLoaded])
//    {
//        [self loadPhoneContacts];
//    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationContactDataChanged:) name:NOTIFICATION_CONTACT_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationSalesforceEnabled:) name:NOTIFICATION_SALESFORCE_ENABLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationSalesforceDisabled:) name:NOTIFICATION_SALESFORCE_DISABLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationPhoneContactUpdated:) name:NOTIFICATION_PHONE_CONTACT_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationSalesforceTokenRefreshed:) name:NOTIFICATION_SALESFORCE_TOKEN_REFRESHED object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectTab:(SelectedTab)tab
{
    
    if (tab == All)
    {
        self.viewTabLineLeadingConstraint.constant = self.btnTabAll.frame.origin.x;
        
        _contactType = nil;
        
    }
    else if (tab == Phone)
    {
        self.viewTabLineLeadingConstraint.constant = self.btnTabPhone.frame.origin.x;
        
        _contactType = CONTACT_TYPE_PHONE;
        
    }
    else if (tab == Email)
    {
        self.viewTabLineLeadingConstraint.constant = self.btnTabEmail.frame.origin.x;
        
        _contactType = CONTACT_TYPE_EMAIL;
        
    }
    else if (tab == Salesforce)
    {
        self.viewTabLineLeadingConstraint.constant = self.btnTabSalesforce.frame.origin.x;
        
        _contactType = CONTACT_TYPE_SALESFORCE;
        
    }
    
    [UIView animateWithDuration:.2f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    currentSelectedTab = tab;
    
    [self.btnTabAll setTitleColor:currentSelectedTab==All?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.btnTabPhone setTitleColor:currentSelectedTab==Phone?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.btnTabEmail setTitleColor:currentSelectedTab==Email?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    [self.btnTabSalesforce setTitleColor:currentSelectedTab==Salesforce?PM_TURQUOISE_COLOR:PM_GREY_COLOR forState:UIControlStateNormal];
    
    [self.btnTabAll.titleLabel setFont:currentSelectedTab==All?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.btnTabPhone.titleLabel setFont:currentSelectedTab==Phone?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.btnTabEmail.titleLabel setFont:currentSelectedTab==Email?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self.btnTabSalesforce.titleLabel setFont:currentSelectedTab==Salesforce?[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    
    [self loadSavedContacts:_contactType];
    
}
# pragma mark notification handler
-(void)handlerNotificationContactDataChanged:(NSNotification *)notification
{
    [self loadSavedContacts:_contactType];
}

-(void)handlerNotificationSalesforceEnabled:(NSNotification *)notification
{
    [self.btnTabSalesforce setEnabled:YES];
}

-(void)handlerNotificationSalesforceDisabled:(NSNotification *)notification
{
    
    [self.btnTabSalesforce setEnabled:NO];
    
    if(currentSelectedTab == Salesforce)
    {
        [self selectTab:All];
        [self loadSavedContacts:nil];
    }
}

-(void)handlerNotificationPhoneContactUpdated:(NSNotification*)notification
{
    [self loadSavedContacts:_contactType];
}
-(void)handleRefresh:(id)sender
{
    [self refreshContacts:_contactType];
    [_refreshControl endRefreshing];
}
- (void)handleNotificationSalesforceTokenRefreshed:(NSNotification*)notification
{
    [self refreshContacts:_contactType];
}
-(void)refreshContacts:(NSString*)contactType
{
    if(!contactType)
    {
        [self loadPhoneContacts];
        if([[PMSettingsManager instance] getEnabledSalesforce]) [self loadSalesforceContacts];
    }
    else if([contactType isEqualToString:CONTACT_TYPE_PHONE])
    {
        [self loadPhoneContacts];
    }
    else if([contactType isEqualToString:CONTACT_TYPE_SALESFORCE])
    {
        [self loadSalesforceContacts];
    }
}

-(void)loadSavedContacts:(NSString*)contactType
{
    [AlertManager showProgressBarWithTitle:@"" view:self.view];
    
    contacts = [NSMutableArray new];
    NSArray *dbSavedContacts = [[DBManager instance] getSavedContactsWithType:contactType];
    
    for(DBSavedContact *contact in dbSavedContacts)
    {
        [contacts addObject:contact];
    }
    
    [self buildData:contacts];
    [AlertManager hideProgressBar];
}

-(void)loadSalesforceContacts
{
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Updating salesforce contacts..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
    [[PMAPIManager shared] getSalesforceContacts:^(id data, id error, BOOL success) {
        [AlertManager hideStatusBar:issuedTime];
       if(success)
       {
           for(DBSavedContact *contact in data)
           {
               NSInteger index = [self indexOfContactWithId:contact.id];
               if(index == NSNotFound)
               {
                   [contacts addObject:contact];
               }
               else
               {
                   [contacts replaceObjectAtIndex:index withObject:contact];
               }
           }
           
           
           [self buildData:contacts];
       }
        else
        {
            [AlertManager showStatusBarWithMessage:@"Loading salesforce contacts failed" type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
        }
    }];
}
- (void)loadPhoneContacts
{
    if(phoneContactLoadingIssuedTime) return;
    phoneContactLoadingIssuedTime = [NSDate date];
    if(contacts.count)
        [AlertManager showStatusBarWithMessage:@"Updating from phone contact..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:phoneContactLoadingIssuedTime];
    else
        [AlertManager showStatusBarWithMessage:@"Creating from phone contact..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:phoneContactLoadingIssuedTime];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        [[CLContactLibrary sharedInstance] getContactArray:^(NSArray *data, NSError *error) {
            
            [AlertManager hideStatusBar:phoneContactLoadingIssuedTime];
            phoneContactLoadingIssuedTime = nil;
        }];
    });
    
    //[[PMSettingsManager instance] setPhoneContactsLoaded:YES];
}
- (NSInteger)indexOfContactWithId:(NSString*)contactId
{
    for(NSInteger index=0; index<contacts.count; index++)
    {
        DBSavedContact *contact = contacts[index];
        if([contactId isEqualToString:contact.id]) return index;
    }
    return NSNotFound;
}


-(void)buildData:(NSArray*)data
{
    [_firstLettersArray removeAllObjects];
    [_itemsArray removeAllObjects];
    
    for(DBSavedContact *contact in data)
    {
        
        NSString *name = [contact getTitle];
        NSString *firstLetter = name&&name.length?[[name substringToIndex:1] uppercaseString]:@"";
        
        
        char c = 0;
        
        if(firstLetter.length)
            c = [firstLetter characterAtIndex:0];
        if(c<'A' || c>'Z')
            firstLetter = @"#";
        
        if(![_firstLettersArray containsObject:firstLetter])
            [_firstLettersArray addObject:firstLetter];
        
        NSMutableArray *itemsForLetter = [_itemsArray objectForKey:firstLetter];
        if(!itemsForLetter)
            itemsForLetter = [NSMutableArray array];
        
        [itemsForLetter addObject:contact];
        
        [_itemsArray setObject:itemsForLetter forKey:firstLetter];
        
        [_firstLettersArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *letter1 = obj1;
            NSString *letter2 = obj2;
            
            char c1 = [letter1 characterAtIndex:0];
            char c2 = [letter2 characterAtIndex:0];
            
            if(c1>='A' && c1<='Z' && c2>='A' && c2<='Z')
                return [letter1 compare:letter2];
            else if(c1>='A' && c1<='Z' && (c2=='#'))
                return NSOrderedAscending;
            else if(c1=='#' && c2>='A' && c2<='Z')
                return NSOrderedDescending;
            else
                return NSOrderedSame;
            
        }];
        
        
    }
    
    [_tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _firstLettersArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return LETTERS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [_firstLettersArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*if (filtered) {
        return [_itemsArrayFiltered count];
    } else {
        return [_itemsArray count];
    }*/
    
    NSString *firstLetter = [_firstLettersArray objectAtIndex:section];
    NSArray *items = [_itemsArray objectForKey:firstLetter];
    return items.count;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(nonnull NSString *)title atIndex:(NSInteger)index
{
    return [_firstLettersArray indexOfObject:title];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[PMContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    NSString *firstLetter = [_firstLettersArray objectAtIndex:indexPath.section];
    NSArray *items = [_itemsArray objectForKey:firstLetter];
    DBSavedContact *contact = [items objectAtIndex:indexPath.row];
    
    
    
    [cell bindContact:contact];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [_searchBar resignFirstResponder];
    
    
    
    NSString *firstLetter = [_firstLettersArray objectAtIndex:indexPath.section];
    NSArray *items = [_itemsArray objectForKey:firstLetter];
    
    DBSavedContact *contact = [items objectAtIndex:indexPath.row];
    
    if(self.isPicker)
    {
        PMCreateContactVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
        
        [contact addEmail:_email];
        
        controller.data = [contact convertToDictionary];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        PMPreviewPeopleVC *lPreviewPeople = [self.storyboard instantiateViewControllerWithIdentifier:@"PMPreviewPeopleVC"];
        lPreviewPeople.contact = contact;
        
        [self.navigationController pushViewController:lPreviewPeople animated:YES];
    }
}
#pragma mark - SearchBarDelegate

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
    if ([text isEqualToString:@""]) {
        filtered = NO;
        [self buildData:contacts];
    } else {
        // Filter the array using NSPredicate
        //NSString *match = [NSString stringWithFormat: @"%@%@", text, @"*"] ;
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName like[cd]  %@)", match];
        //_itemsArrayFiltered = [_itemsArray filteredArrayUsingPredicate:predicate];
        
        //[_tableView reloadData];
        
        if(filteredContacts==nil) filteredContacts = [NSMutableArray new];
        [filteredContacts removeAllObjects];
        filtered = YES;
        
        for(DBSavedContact *contact in contacts)
        {
            NSString *name = [[contact getTitle] lowercaseString];
            if(name)
            {
                NSRange rangeName = [name rangeOfString:[text lowercaseString]];
                if(rangeName.location!=NSNotFound)
                {
                    [filteredContacts addObject:contact]; continue;
                }
            }
            
            NSString *email = [contact getFirstEmailAddress];
            if(email)
            {
                NSRange rangeEmail = [email rangeOfString:text];
                if(rangeEmail.location != NSNotFound)
                {
                    [filteredContacts addObject:contact];
                }
            }
        }
        
        [self buildData:filteredContacts];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    filtered = NO;
    [self buildData:contacts];
}

- (IBAction)createContactAction:(id)sender
{
    PMCreateContactVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
    
    [self presentViewController:vc animated:YES completion:nil];
}


- (IBAction)btnTabAllClicked:(id)sender {
    [self selectTab:All];
}

- (IBAction)btnTabPhoneClicked:(id)sender {
    [self selectTab:Phone];

}

- (IBAction)btnTabEmailClicked:(id)sender {
    [self selectTab:Email];

}

- (IBAction)btnTabSalesforceClicked:(id)sender {
    [self selectTab:Salesforce];

}
@end
