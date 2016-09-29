//
//  PMSFCreateContactVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFLeadDetailsVC.h"
#import "PMSFCreateLeadNC.h"

#import "PMTextFieldTVCell.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "ActionSheetStringPicker.h"
#import "PMSettingsManager.h"
#import "PMSFUserListVC.h"
#import "Config.h"
#import "PMDraftModel.h"
#import "PMMailComposeVC.h"

#define SECTION_LEAD_INFO @"LEAD INFORMATION"
#define SECTION_ADDRESS_INFO @"ADDRESS INFORMATION"

#define STATUSES @[@"Unqualified", @"New", @"Working", @"Nurturing", @"Qualified"]
#define SALUTATIONS @[@"Mr.", @"Ms.", @"Mrs.", @"Dr.", @"Prof."]
#define RATINGS @[@"Hot", @"Warm", @"Cold"]
#define INDUSTRIES @[@"Agriculture", @"Apparel", @"Banking", @"Biotechnology", @"Chemicals", @"Communications", @"Construction", @"Consulting", @"Education", @"Electronics", @"Energy", @"Engineering", @"Entertainment", @"Environmental", @"Finance", @"Food & Beverage", @"Government", @"Healthcare", @"Hospitality", @"Insurance", @"Machinery", @"Manufacturing", @"Media", @"Not For Profit", @"Other", @"Recreation", @"Retail", @"Shipping", @"Technology", @"Telecommunications", @"Transportation", @"Utilities"]
#define LEAD_SOURCES @[@"Advertisement", @"Customer Event", @"Employee Referral", @"Google AdWords", @"Other", @"Partner", @"Purchased List", @"Trade Show", @"Webinar", @"Website"]



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




@interface PMSFLeadDetailsVC () <UITableViewDataSource, UITableViewDelegate>
{
    UITableViewCell *firstResponderCell;
    CGFloat keyboardHeight;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *items;

@property (nonatomic, strong) NSString *ownerName;
- (IBAction)actionEditTap:(id)sender;
@end

@implementation PMSFLeadDetailsVC

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
    
    
    NSDictionary *salesforceUserInfo = [[PMSettingsManager instance] getSalesforceUserInfo];
    if(salesforceUserInfo)
    {
        _ownerName = salesforceUserInfo[@"display_name"];
    }
    
    [self setNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    [self.navigationItem setTitle:_data[@"Name"]];
}

-(void) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellIdentifier = [cell reuseIdentifier];
    
    if([cellIdentifier isEqualToString:LEAD_EMAIL_CELL])
    {
        NSString *email = _data[@"Email"];
        if(email && email.length)
        {
            NSDictionary *draftData = @{@"name": _data[@"Name"], @"email": email};
            NSArray *to = @[draftData];
            PMDraftModel *lDraft = [PMDraftModel new];
            lDraft.to = to;
            
            PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
            lNewMailComposeVC.draft = lDraft;
            [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
        }
    }
    else if([cellIdentifier isEqualToString:LEAD_PHONE_CELL])
    {
        NSString *phoneNumber = _data[@"Phone"];
        if(phoneNumber && phoneNumber.length)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if([cellIdentifier isEqualToString:LEAD_MOBILE_PHONE_CELL])
    {
        NSString *phoneNumber = _data[@"MobilePhone"];
        if(phoneNumber && phoneNumber.length)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
- (IBAction)actionEditTap:(id)sender
{
    PMSFCreateLeadNC *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFCreateLeadNC"];
    
    nc.isUpdate = YES;
    nc.data = self.data;
    
    [self presentViewController:nc animated:YES completion:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveSuccess:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceLeadSaveFailure:) name:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil];
}

#pragma mark SalesforceLeadSave Notification Handler
- (void)handleSalesforceLeadSaveSuccess:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Salesforce lead saved." type:ACTIVITY_STATUS_TYPE_INFO view:self.view time:nil];
    
    _data = [notification userInfo];
    
    NSMutableString *name = [NSMutableString new];
    if(_data[@"FirstName"]) [name appendFormat:@"%@ ", _data[@"FirstName"]];
    if(_data[@"LastName"]) [name appendFormat:@"%@", _data[@"LastName"]];
    [self.navigationItem setTitle:name];
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil];
}

- (void)handleSalesforceLeadSaveFailure:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Saving salesforce lead failed." type:ACTIVITY_STATUS_TYPE_ERROR view:self.view time:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED object:nil];
}
@end
