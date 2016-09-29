//
//  PMSFCreateContactVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFCreateContactVC.h"
#import "PMSFCreateContactNC.h"

#import "PMTextFieldTVCell.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "ActionSheetStringPicker.h"
#import "PMSettingsManager.h"
#import "PMSFUserListVC.h"
#import "PMSFAccountListVC.h"
#import "PMSFContactListVC.h"

#define SECTION_CONTACT_INFO @"CONTACT INFORMATION"
#define SECTION_ADDRESS_INFO @"ADDRESS INFORMATION"

#define SALUTATIONS @[@"Mr.", @"Ms.", @"Mrs.", @"Dr.", @"Prof."]

@interface PMSFCreateContactVC () <UITableViewDataSource, UITableViewDelegate, PMTextFieldTVCellDelegate, PMSFUserListVCDelegate, PMSFAccountListVCDelegate, PMSFContactListVCDelegate>
{
    UITableViewCell *firstResponderCell;
    CGFloat keyboardHeight;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;



@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *items;

@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *reportsToName;
@end

@implementation PMSFCreateContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sections = @[SECTION_CONTACT_INFO, SECTION_ADDRESS_INFO];
    
    _items = @{SECTION_CONTACT_INFO: @[
                       @"sfContactSalutationCell",
                       @"sfContactFirstNameCell",
                       @"sfContactMiddleNameCell",
                       @"sfContactLastNameCell",
                       @"sfContactSuffixCell",
                       @"sfContactAccountCell",
                       @"sfContactTitleCell",
                       @"sfContactEmailCell",
                       @"sfContactBusinessPhoneCell",
                       @"sfContactMobilePhoneCell",
                       @"sfContactOwnerCell",
                       @"sfContactReportsToCell",
                       @"sfContactDepartmentCell",
                       @"sfContactBusinessFaxCell"],
               SECTION_ADDRESS_INFO: @[
                       @"sfContactMailingStreetCell",
                       @"sfContactMailingCityCell",
                       @"sfContactMailingStateCell",
                       @"sfContactMailingZipCell",
                       @"sfContactMailingCountryCell",
                       ]
               };
    
    _isUpdate = ((PMSFCreateContactNC*)self.navigationController).isUpdate;
    _data = [NSMutableDictionary dictionaryWithDictionary:((PMSFCreateContactNC*)self.navigationController).data];
    if(_isUpdate)
        [self.navigationItem setTitle:@"Update Contact"];
    else
    {
        [self.navigationItem setTitle:@"Create Contact"];
    }
    
    NSDictionary *salesforceUserInfo = [[PMSettingsManager instance] getSalesforceUserInfo];
    if(salesforceUserInfo)
    {
        _ownerName = salesforceUserInfo[@"display_name"];
        [_data setObject:salesforceUserInfo[@"user_id"] forKey:@"OwnerId"];
    }
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
    
    [AlertManager showProgressBarWithTitle:@"Saving..." view:self.tableView];
    [[PMAPIManager shared] saveSalesforceContact:_data completion:^(id data, id error, BOOL success) {
        [AlertManager hideProgressBar];
        if(success)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                if([self.delegate respondsToSelector:@selector(sfCreateContactVC:didSaveContactData:)])
                    [self.delegate sfCreateContactVC:self didSaveContactData:_data];
            }];
        }
        else
        {
            [AlertManager showErrorMessage:@"Save salesforce contact failed"];
        }
        
    }];
}

-(BOOL)validateData
{
    NSString *lastName = _data[@"LastName"];
    if(!lastName || lastName.length==0)
    {
        [AlertManager showErrorMessage:@"The Last Name is required."];
        return NO;
    }
    
    NSString *accountId = _data[@"AccountId"];
    if(!accountId || accountId.length==0)
    {
        [AlertManager showErrorMessage:@"The Account is required."];
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
    //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y+dy)];
    
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
    if(section==0) return ((NSArray*)_items[SECTION_CONTACT_INFO]).count;
    else if(section==1) return ((NSArray*)_items[SECTION_ADDRESS_INFO]).count;
    
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = _items[_sections[indexPath.section]][indexPath.row];
    PMTextFieldTVCell *cell = (PMTextFieldTVCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.delegate = self;
    
    if([cellIdentifier isEqualToString:@"sfContactSalutationCell"])
    {
        [cell.textField setText:_data[@"Salutation"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactFirstNameCell"])
    {
        [cell.textField setText:_data[@"FirstName"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMiddleNameCell"])
    {
        [cell.textField setText:_data[@"MiddleName"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactLastNameCell"])
    {
        [cell.textField setText:_data[@"LastName"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactSuffixCell"])
    {
        [cell.textField setText:_data[@"Suffix"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactAccountCell"])
    {
        [cell.textField setText:_accountName];
    }
    else if([cellIdentifier isEqualToString:@"sfContactTitleCell"])
    {
        [cell.textField setText:_data[@"Title"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactEmailCell"])
    {
        [cell.textField setText:_data[@"Email"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactBusinessPhoneCell"])
    {
        [cell.textField setText:_data[@"Phone"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMobilePhoneCell"])
    {
        [cell.textField setText:_data[@"MobilePhone"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactOwnerCell"])
    {
        [cell.textField setText:_ownerName];
    }
    else if([cellIdentifier isEqualToString:@"sfContactReportsToCell"])
    {
        [cell.textField setText:_reportsToName];
    }
    else if([cellIdentifier isEqualToString:@"sfContactDepartmentCell"])
    {
        [cell.textField setText:_data[@"Department"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactBusinessFaxCell"])
    {
        [cell.textField setText:_data[@"Fax"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMailingStreetCell"])
    {
        [cell.textField setText:_data[@"MailingStreet"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMailingCityCell"])
    {
        [cell.textField setText:_data[@"MailingCity"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMailingStateCell"])
    {
        [cell.textField setText:_data[@"MailingState"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMailingZipCell"])
    {
        [cell.textField setText:_data[@"MailingPostalCode"]];
    }
    else if([cellIdentifier isEqualToString:@"sfContactMailingCountryCell"])
    {
        [cell.textField setText:_data[@"MailingCountry"]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PMTextFieldTVCell *cell = (PMTextFieldTVCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString* cellIdentifier = cell.reuseIdentifier;
    
    
    if([cellIdentifier isEqualToString:@"sfContactSalutationCell"])
    {
        [self.view endEditing:YES];
        
        NSString *salutation = _data[@"Salutation"];
        NSInteger index = salutation?[SALUTATIONS indexOfObject:salutation]:0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Salutation"
                                                rows:SALUTATIONS
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               [_data setObject:selectedValue forKey:@"Salutation"];
                                               
                                               [cell.textField setText:selectedValue];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:@"sfContactOwnerCell"])
    {
        [self.view endEditing:YES];
        PMSFUserListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFUserListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"sfContactAccountCell"])
    {
        [self.view endEditing:YES];
        PMSFAccountListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFAccountListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([cellIdentifier isEqualToString:@"sfContactReportsToCell"])
    {
        [self.view endEditing:YES];
        PMSFContactListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFContactListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark PMTextFieldTVCellDelegate
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString *)text {
    if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactFirstNameCell"]) {
        [_data setObject:text forKey:@"FirstName"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMiddleNameCell"]) {
        [_data setObject:text forKey:@"MiddleName"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactLastNameCell"]) {
        [_data setObject:text forKey:@"LastName"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactSuffixCell"]) {
        [_data setObject:text forKey:@"Suffix"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactTitleCell"]) {
        [_data setObject:text forKey:@"Title"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactEmailCell"]) {
        [_data setObject:text forKey:@"Email"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactBusinessPhoneCell"]) {
        [_data setObject:text forKey:@"Phone"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMobilePhoneCell"]) {
        [_data setObject:text forKey:@"MobilePhone"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactBusinessFaxCell"]) {
        [_data setObject:text forKey:@"Fax"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactDepartmentCell"]) {
        [_data setObject:text forKey:@"Department"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMailingStreetCell"]) {
        [_data setObject:text forKey:@"MailingStreet"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMailingCityCell"]) {
        [_data setObject:text forKey:@"MailingCity"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMailingStateCell"]) {
        [_data setObject:text forKey:@"MailingState"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMalingPostalCodeCell"]) {
        [_data setObject:text forKey:@"MailingPostalCode"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfContactMailingCountryCell"]) {
        [_data setObject:text forKey:@"MailingCountry"];
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

#pragma mark PMSFAccountListVCDelegate
-(void)accountListVC:(PMSFAccountListVC *)vc didSelectAccount:(NSDictionary *)accountData
{
    _accountName = accountData[@"Name"];
    _data[@"AccountId"] = accountData[@"Id"];
    
    [_tableView reloadData];
}

#pragma mark PMSFContactListVCDelegate
-(void)contactListVC:(PMSFContactListVC *)vc didSelectContact:(NSDictionary *)contactData
{
    _reportsToName = contactData[@"Name"];
    _data[@"ReportsToId"] = contactData[@"Id"];
    
    [_tableView reloadData];
}
@end
