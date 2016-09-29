//
//  PMSFCreateContactVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFCreateLeadVC.h"
#import "PMSFCreateLeadNC.h"

#import "PMTextFieldTVCell.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "ActionSheetStringPicker.h"
#import "PMSettingsManager.h"
#import "PMSFUserListVC.h"
#import "Config.h"

#define SECTION_LEAD_INFO @"LEAD INFORMATION"
#define SECTION_ADDRESS_INFO @"ADDRESS INFORMATION"


#define LEAD_STATUS_CELL @"sfLeadStatusCell"
#define LEAD_SALUTATION_CELL @"sfLeadSalutationCell"
#define LEAD_FIRST_NAME_CELL @"sfLeadFirstNameCell"
#define LEAD_LAST_NAME_CELL @"sfLeadLastNameCell"
#define LEAD_TITLE_CELL @"sfLeadTitleCell"
#define LEAD_EMAIL_CELL @"sfLeadEmailCell"
#define LEAD_PHONE_CELL @"sfLeadPhoneCell"
#define LEAD_MOBILE_PHONE_CELL @"sfLeadMobilePhoneCell"
#define LEAD_FAX_CELL @"sfLeadFaxCell"
#define LEAD_RATING_CELL @"sfLeadRatingCell"
#define LEAD_OWNER_CELL @"sfLeadOwnerCell"
#define LEAD_WEBSITE_CELL @"sfLeadWebsiteCell"
#define LEAD_COMPANY_CELL @"sfLeadCompanyCell"
#define LEAD_INDUSTRY_CELL @"sfLeadIndustryCell"
#define LEAD_ANNUAL_REVENUE_CELL @"sfLeadAnnualRevenueCell"
#define LEAD_EMPLOYEES_CELL @"sfLeadEmployeesCell"
#define LEAD_SOURCE_CELL @"sfLeadSourceCell"
#define LEAD_STREET_CELL @"sfLeadStreetCell"
#define LEAD_CITY_CELL @"sfLeadCityCell"
#define LEAD_STATE_CELL @"sfLeadStateCell"
#define LEAD_ZIP_CELL @"sfLeadZipCell"
#define LEAD_COUNTRY_CELL @"sfLeadCountryCell"
                        
                        


@interface PMSFCreateLeadVC () <UITableViewDataSource, UITableViewDelegate, PMTextFieldTVCellDelegate, PMSFUserListVCDelegate>
{
    UITableViewCell *firstResponderCell;
    CGFloat keyboardHeight;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *items;

@property (nonatomic, strong) NSString *ownerName;


@property (nonatomic, strong) NSMutableArray *leadStatusArray;
@property (nonatomic, strong) NSMutableArray *leadSourceArray;
@property (nonatomic, strong) NSMutableArray *salutationArray;
@property (nonatomic, strong) NSMutableArray *industryArray;
@property (nonatomic, strong) NSMutableArray *ratingArray;
@end

@implementation PMSFCreateLeadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sections = @[SECTION_LEAD_INFO, SECTION_ADDRESS_INFO];
    
    _items = @{SECTION_LEAD_INFO: @[
                       LEAD_STATUS_CELL,
                       LEAD_SALUTATION_CELL,
                       LEAD_FIRST_NAME_CELL,
                       LEAD_LAST_NAME_CELL,
                       LEAD_TITLE_CELL,
                       LEAD_EMAIL_CELL,
                       LEAD_PHONE_CELL,
                       LEAD_MOBILE_PHONE_CELL,
                       LEAD_FAX_CELL,
                       LEAD_RATING_CELL,
                       LEAD_OWNER_CELL,
                       LEAD_WEBSITE_CELL,
                       LEAD_COMPANY_CELL,
                       LEAD_INDUSTRY_CELL,
                       LEAD_ANNUAL_REVENUE_CELL,
                       LEAD_EMPLOYEES_CELL,
                       LEAD_SOURCE_CELL],
               SECTION_ADDRESS_INFO: @[
                       LEAD_STREET_CELL,
                       LEAD_CITY_CELL,
                       LEAD_STATE_CELL,
                       LEAD_ZIP_CELL,
                       LEAD_COUNTRY_CELL,
                       ]
               };
    
    _isUpdate = ((PMSFCreateLeadNC*)self.navigationController).isUpdate;
    _data = [NSMutableDictionary dictionaryWithDictionary:((PMSFCreateLeadNC*)self.navigationController).data];
    if(_isUpdate)
        [self.navigationItem setTitle:@"Update Lead"];
    else
    {
        [self.navigationItem setTitle:@"Create Lead"];
    }
    
    NSDictionary *salesforceUserInfo = [[PMSettingsManager instance] getSalesforceUserInfo];
    if(salesforceUserInfo)
    {
        _ownerName = salesforceUserInfo[@"display_name"];
        [_data setObject:salesforceUserInfo[@"user_id"] forKey:@"OwnerId"];
    }
    
    _leadStatusArray = [NSMutableArray new];

    
    [[PMAPIManager shared] getSalesforceLeadStatusList:^(id data, id error, BOOL success) {
        if(success)
        {
            for(NSDictionary *item in data)
            {
                [_leadStatusArray addObject:item[@"MasterLabel"]];
            }
        }
    }];
    
    [[PMAPIManager shared] getSalesforcePicklistValuesForLead:^(id data, id error, BOOL success) {
        if(success)
        {
            _leadSourceArray = data[@"LeadSource"];
            _salutationArray = data[@"Salutation"];
            _industryArray = data[@"Industry"];
            _ratingArray = data[@"Rating"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (IBAction)cancelActionTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveActionTap:(id)sender
{
    [self.view endEditing:YES];
    if(![self validateData]) return;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSDate *issuedTime = [NSDate date];
        [AlertManager showStatusBarWithMessage:@"Saving salesforce opportunity..." type:ACTIVITY_STATUS_TYPE_PROGRESS view:self.navigationController.parentViewController.view time:issuedTime];
        
        [[PMAPIManager shared] saveSalesforceLead:_data completion:^(id data, id error, BOOL success) {
            [AlertManager hideStatusBar:issuedTime];
            if(success)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil userInfo:_data];
                
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil userInfo:_data];
                
            }
            
        }];
    }];
    
    
}

-(BOOL)validateData
{
    
    NSString *status = _data[@"Status"];
    if(!status || status.length==0)
    {
        [AlertManager showErrorMessage:@"The Status is required."];
        return NO;
    }
    
    NSString *lastName = _data[@"LastName"];
    if(!lastName || lastName.length==0)
    {
        [AlertManager showErrorMessage:@"The Last Name is required."];
        return NO;
    }
    
    NSString *company = _data[@"Company"];
    if(!company || company.length==0)
    {
        [AlertManager showErrorMessage:@"The Company is required."];
        return NO;
    }
    
    return YES;
}
#pragma mark Keyboard Show/Hide Handler
- (void)keyboardDidShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(keyboardHeight == 0)
    {
        keyboardHeight = keyboardSize.height;
        [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+keyboardHeight)];
        
        
        CGRect superRect = self.view.frame;
        CGRect cellRect = firstResponderCell.frame;
        CGPoint contentOffset = self.tableView.contentOffset;
        CGFloat dy = (cellRect.origin.y - contentOffset.y) - (superRect.size.height - keyboardHeight);//superRect.size.height - keyboardSize.height - cellRect.origin.y;
        
        if(dy>0)
            [self.tableView setContentOffset:CGPointMake(0, contentOffset.y+dy+150)];
        
        [UIView animateWithDuration:0.25f animations:^{
            
        }];
    }
    
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height-keyboardHeight)];
    
    keyboardHeight = 0;
}

#pragma mark UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0) return ((NSArray*)_items[SECTION_LEAD_INFO]).count;
    else if(section==1) return ((NSArray*)_items[SECTION_ADDRESS_INFO]).count;
    
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = _items[_sections[indexPath.section]][indexPath.row];
    PMTextFieldTVCell *cell = (PMTextFieldTVCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.delegate = self;
    
    if([cellIdentifier isEqualToString:LEAD_STATUS_CELL])
    {
        [cell.textField setText:_data[@"Status"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_SALUTATION_CELL])
    {
        [cell.textField setText:_data[@"Salutation"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_FIRST_NAME_CELL])
    {
        [cell.textField setText:_data[@"FirstName"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_LAST_NAME_CELL])
    {
        [cell.textField setText:_data[@"LastName"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_TITLE_CELL])
    {
        [cell.textField setText:_data[@"Title"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_EMAIL_CELL])
    {
        [cell.textField setText:_data[@"Email"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_PHONE_CELL])
    {
        [cell.textField setText:_data[@"Phone"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_MOBILE_PHONE_CELL])
    {
        [cell.textField setText:_data[@"MobilePhone"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_FAX_CELL])
    {
        [cell.textField setText:_data[@"Fax"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_RATING_CELL])
    {
        [cell.textField setText:_data[@"Rating"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_OWNER_CELL])
    {
        [cell.textField setText:_ownerName];
    }
    else if([cellIdentifier isEqualToString:LEAD_WEBSITE_CELL])
    {
        [cell.textField setText:_data[@"Website"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_COMPANY_CELL])
    {
        [cell.textField setText:_data[@"Company"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_INDUSTRY_CELL])
    {
        [cell.textField setText:_data[@"Industry"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_EMPLOYEES_CELL])
    {
        NSNumber *value = notNullValue(_data[@"AnnualRevenue"]);
        [cell.textField setText:value?[NSString stringWithFormat:@"%1.2f", [value doubleValue]]:@""];
        cell.delegate = self;
    }
    else if([cellIdentifier isEqualToString:LEAD_EMPLOYEES_CELL])
    {
        NSNumber *employees = _data[@"NumberOfEmployees"];
        [cell.textField setText:employees?[NSString stringWithFormat:@"%@",employees]:nil];
    }
    else if([cellIdentifier isEqualToString:LEAD_SOURCE_CELL])
    {
        [cell.textField setText:_data[@"LeadSource"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_STREET_CELL])
    {
        [cell.textField setText:_data[@"Street"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_CITY_CELL])
    {
        [cell.textField setText:_data[@"City"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_STATE_CELL])
    {
        [cell.textField setText:_data[@"State"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_ZIP_CELL])
    {
        [cell.textField setText:_data[@"PostalCode"]];
    }
    else if([cellIdentifier isEqualToString:LEAD_COUNTRY_CELL])
    {
        [cell.textField setText:_data[@"Country"]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PMTextFieldTVCell *cell = (PMTextFieldTVCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString* cellIdentifier = cell.reuseIdentifier;
    
    if([cellIdentifier isEqualToString:LEAD_STATUS_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *status = _data[@"Status"];
        NSInteger index = [_leadStatusArray indexOfObject:status];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Status"
                                                rows:_leadStatusArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"Status"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:LEAD_SALUTATION_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *salutation = _data[@"Salutation"];
        NSInteger index = [_salutationArray indexOfObject:salutation];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Salutation"
                                                rows:_salutationArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"Salutation"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:LEAD_RATING_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *rating = _data[@"Rating"];
        NSInteger index = [_ratingArray indexOfObject:rating];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Rating"
                                                rows:_ratingArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"Rating"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:LEAD_INDUSTRY_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *industry = _data[@"Industry"];
        NSInteger index = [_industryArray indexOfObject:industry];
        if(index == NSNotFound) index = 0;
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select Industry"
                                                rows:_industryArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"Industry"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:LEAD_SOURCE_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *leadSource = _data[@"LeadSource"];
        NSInteger index = [_leadSourceArray indexOfObject:leadSource];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select LeadSource"
                                                rows:_leadSourceArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"LeadSource"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:LEAD_OWNER_CELL])
    {
        [self.view endEditing:YES];
        PMSFUserListVC *vc = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFUserListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark PMTextFieldTVCellDelegate
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString *)text {
    if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_FIRST_NAME_CELL]) {
        [_data setObject:text forKey:@"FirstName"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_LAST_NAME_CELL]) {
        [_data setObject:text forKey:@"LastName"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_TITLE_CELL]) {
        [_data setObject:text forKey:@"Title"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_EMAIL_CELL]) {
        [_data setObject:text forKey:@"Email"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_PHONE_CELL]) {
        [_data setObject:text forKey:@"Phone"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_MOBILE_PHONE_CELL]) {
        [_data setObject:text forKey:@"MobilePhone"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_FAX_CELL]) {
        [_data setObject:text forKey:@"Fax"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_WEBSITE_CELL]) {
        [_data setObject:text forKey:@"Website"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_COMPANY_CELL]) {
        [_data setObject:text forKey:@"Company"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_ANNUAL_REVENUE_CELL]) {
        [_data setObject:text forKey:@"AnnualRevenue"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_EMPLOYEES_CELL]) {
        [_data setObject:text forKey:@"NumberOfEmployees"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_STREET_CELL]) {
        [_data setObject:text forKey:@"Street"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_CITY_CELL]) {
        [_data setObject:text forKey:@"City"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_STATE_CELL]) {
        [_data setObject:text forKey:@"State"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_ZIP_CELL]) {
        [_data setObject:text forKey:@"PostalCode"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:LEAD_COUNTRY_CELL]) {
        [_data setObject:text forKey:@"Country"];
    }
    
}
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell getFocus:(UITextField *)textField
{
    firstResponderCell = textFieldTVCell;
}

#pragma mark PMSFUserListVCDelegate
-(void)userListVC:(PMSFUserListVC *)vc didSelectUser:(NSDictionary *)userData
{
    _ownerName = userData[@"Name"];
    _data[@"OwnerId"] = userData[@"Id"];
    
    [_tableView reloadData];
}

@end
