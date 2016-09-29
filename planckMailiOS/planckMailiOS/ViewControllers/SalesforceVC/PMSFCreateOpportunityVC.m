//
//  PMSFCreateOpportunityVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/26/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFCreateOpportunityVC.h"
#import "PMSFCreateOpportunityNC.h"
#import "PMTextFieldTVCell.h"
#import "PMTextViewTVCell.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "ActionSheetStringPicker.h"
#import "AIDatePickerController.h"
#import "PMSettingsManager.h"
#import "PMSFUserListVC.h"
#import "PMSFAccountListVC.h"
#import "PMSFCampaignListVC.h"
#import "Config.h"

#define SECTION_OPPORTUNITY_INFO @"OPPORTUNITY INFORMATION"
#define SECTION_ADDITIONAL_INFO @"ADDITIONAL INFORMATION"



#define OPPORTUNITY_NAME_CELL @"sfOpportunityNameCell"
#define OPPORTUNITY_ACCOUNT_CELL @"sfOpportunityAccountCell"
#define OPPORTUNITY_TYPE_CELL @"sfOpportunityTypeCell"
#define OPPORTUNITY_CAMPAIGN_CELL @"sfOpportunityCampaignCell"
#define OPPORTUNITY_OWNER_CELL @"sfOpportunityOwnerCell"
#define OPPORTUNITY_CLOSE_DATE_CELL @"sfOpportunityCloseDateCell"
#define OPPORTUNITY_STAGE_CELL @"sfOpportunityStageCell"
#define OPPORTUNITY_PROBABILITY_CELL @"sfOpportunityProbabilityCell"
#define OPPORTUNITY_AMOUNT_CELL @"sfOpportunityAmountCell"
#define OPPORTUNITY_NEXT_STEP_CELL @"sfOpportunityNextStepCell"
#define OPPORTUNITY_LEAD_SOURCE_CELL @"sfOpportunityLeadSourceCell"
#define OPPORTUNITY_DESCRIPTION_CELL @"sfOpportunityDescriptionCell"



@interface PMSFCreateOpportunityVC () <UITableViewDataSource, UITableViewDelegate, PMTextFieldTVCellDelegate, PMTextViewTVCellDelegate, PMSFUserListVCDelegate, PMSFAccountListVCDelegate, PMSFCampaignListVCDelegate>
{
    UITableViewCell *firstResponderCell;
    CGFloat keyboardHeight;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *items;

@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *campaignName;

@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) NSMutableArray *leadSourceArray;
@property (nonatomic, strong) NSMutableArray *stageArray;
@property (nonatomic, strong) NSMutableDictionary *probabilityData;
@end

@implementation PMSFCreateOpportunityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sections = @[SECTION_OPPORTUNITY_INFO, SECTION_ADDITIONAL_INFO];
    
    _items = @{SECTION_OPPORTUNITY_INFO: @[
                       OPPORTUNITY_NAME_CELL,
                       OPPORTUNITY_ACCOUNT_CELL,
                       OPPORTUNITY_TYPE_CELL,
                       OPPORTUNITY_LEAD_SOURCE_CELL,
                       OPPORTUNITY_CAMPAIGN_CELL,
                       OPPORTUNITY_OWNER_CELL,
                       OPPORTUNITY_CLOSE_DATE_CELL,
                       OPPORTUNITY_NEXT_STEP_CELL,
                       OPPORTUNITY_STAGE_CELL,
                       OPPORTUNITY_PROBABILITY_CELL,
                       OPPORTUNITY_AMOUNT_CELL],
               SECTION_ADDITIONAL_INFO: @[
                       OPPORTUNITY_DESCRIPTION_CELL
                       ]
               };
    
    
    _isUpdate = ((PMSFCreateOpportunityVC*)self.navigationController).isUpdate;
    _data = [NSMutableDictionary dictionaryWithDictionary:((PMSFCreateOpportunityNC*)self.navigationController).data];
    
    NSLog(@"%@", _data);
    if(_isUpdate)
        [self.navigationItem setTitle:@"Update Opportunity"];
    else
    {
        [self.navigationItem setTitle:@"Create Opportunity"];
    }
    
    NSDictionary *salesforceUserInfo = [[PMSettingsManager instance] getSalesforceUserInfo];
    if(salesforceUserInfo)
    {
        _ownerName = salesforceUserInfo[@"display_name"];
        [_data setObject:salesforceUserInfo[@"user_id"] forKey:@"OwnerId"];
    }
    
    if(_data)
    {
        _accountName = _data[@"AccountName"];
        _campaignName = _data[@"CampaignName"];
        
        [_data removeObjectForKey:@"AccountName"];
        [_data removeObjectForKey:@"OwnerName"];
        [_data removeObjectForKey:@"CampaignName"];
    }
    
    _stageArray = [NSMutableArray new];
    _typeArray = [NSMutableArray new];
    _leadSourceArray = [NSMutableArray new];
    _probabilityData = [NSMutableDictionary new];
    [[PMAPIManager shared] getSalesforceOpportunityStageList:^(id data, id error, BOOL success) {
        if(success)
        {
            for(NSDictionary *item in data)
            {
                [_stageArray addObject:item[@"MasterLabel"]];
                [_probabilityData setObject:item[@"DefaultProbability"] forKey:item[@"MasterLabel"]];
            }
            
        }
    }];
    
    [[PMAPIManager shared] getSalesforcePicklistValuesForOpportunity:^(id data, id error, BOOL success) {
        if(success)
        {
            _leadSourceArray = data[@"LeadSource"];
            _typeArray = data[@"Type"];
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
        
        [[PMAPIManager shared] saveSalesforceOpportunity:_data completion:^(id data, id error, BOOL success) {
            [AlertManager hideStatusBar:issuedTime];
            if(success)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil userInfo:_data];
                
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil userInfo:_data];
                
            }
            
        }];
    }];
}

-(BOOL)validateData
{
    NSString *name = notNullValue(_data[@"Name"]);
    if(!name || name.length==0)
    {
        [AlertManager showErrorMessage:@"The Opportunity Name is required."];
        return NO;
    }
    
    NSString *accountId = notNullValue(_data[@"AccountId"]);
    if(!accountId || accountId.length==0)
    {
        [AlertManager showErrorMessage:@"The Account is required."];
        return NO;
    }
    
    NSString *closeDate = notNullValue(_data[@"CloseDate"]);
    if(!closeDate || closeDate.length==0)
    {
        [AlertManager showErrorMessage:@"The Close Date is required."];
        return NO;
    }
    
    NSString *stageName = notNullValue(_data[@"StageName"]);
    if(!stageName || stageName.length==0)
    {
        [AlertManager showErrorMessage:@"The Stage Name is required."];
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
    if(section==0) return ((NSArray*)_items[SECTION_OPPORTUNITY_INFO]).count;
    else if(section==1) return ((NSArray*)_items[SECTION_ADDITIONAL_INFO]).count;
    
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1 && indexPath.row==0)
        return 150;
    return 75;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = _items[_sections[indexPath.section]][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if([cellIdentifier isEqualToString:OPPORTUNITY_NAME_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"Name"]];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_ACCOUNT_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_accountName];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_TYPE_CELL])
    {
        NSString *type = notNullEmptyString(_data[@"Type"]);
        [((PMTextFieldTVCell*)cell).textField setText:type];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CAMPAIGN_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_campaignName];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_OWNER_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_ownerName];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CLOSE_DATE_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"CloseDate"]];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_STAGE_CELL])
    {
        NSString *stageName = notNullEmptyString(_data[@"StageName"]);
        [((PMTextFieldTVCell*)cell).textField setText:stageName];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_PROBABILITY_CELL])
    {
        NSNumber *probability = notNullValue(_data[@"Probability"]);
        [((PMTextFieldTVCell*)cell).textField setText:probability?[probability stringValue]:@""];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_AMOUNT_CELL])
    {
        NSNumber *amount = notNullValue(_data[@"Amount"]);
        [((PMTextFieldTVCell*)cell).textField setText:amount?[NSString stringWithFormat:@"%1.2f", [amount doubleValue]]:@""];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_NEXT_STEP_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"NextStep"]];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_LEAD_SOURCE_CELL])
    {
        NSString *leadSource = notNullEmptyString(_data[@"LeadSource"]);
        [((PMTextFieldTVCell*)cell).textField setText:leadSource];
        ((PMTextFieldTVCell*)cell).delegate = self;
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_DESCRIPTION_CELL])
    {
        NSString *oppDescription = notNullEmptyString(_data[@"Description"]);
        [((PMTextViewTVCell*)cell).textView setText:oppDescription];
        ((PMTextViewTVCell*)cell).delegate = self;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString* cellIdentifier = cell.reuseIdentifier;
    
    
    if([cellIdentifier isEqualToString:OPPORTUNITY_TYPE_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *type = notNullValue(_data[@"Type"]);
        NSInteger index = [_typeArray indexOfObject:type];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Opportunity Type"
                                                rows:_typeArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               if(![selectedValue isEqualToString:@"--None--"])
                                                   [_data setObject:selectedValue forKey:@"Type"];
                                               else
                                                   [_data removeObjectForKey:@"Type"];
                                               [_tableView reloadData];
                                               
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_STAGE_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *stage = notNullValue(_data[@"StageName"]);
        NSInteger index = [_stageArray indexOfObject:stage];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Stage"
                                                rows:_stageArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               if(![selectedValue isEqualToString:@"--None--"])
                                               {
                                                   [_data setObject:selectedValue forKey:@"StageName"];
                                                   
                                                   [_data setObject:_probabilityData[selectedValue] forKey:@"Probability"];
                                               }
                                               else
                                               {
                                                   [_data removeObjectForKey:@"StageName"];
                                               }
                                               
                                               [_tableView reloadData];
                                               
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_LEAD_SOURCE_CELL])
    {
        [self.view endEditing:YES];
        
        NSString *leadSource = notNullValue(_data[@"LeadSource"]);
        NSInteger index = [_leadSourceArray indexOfObject:leadSource];
        if(index == NSNotFound) index = 0;
        [ActionSheetStringPicker showPickerWithTitle:@"Select Lead Source"
                                                rows:_leadSourceArray
                                    initialSelection:index
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               if(![selectedValue isEqualToString:@"--None--"])
                                                   [_data setObject:selectedValue forKey:@"LeadSource"];
                                               else
                                                   [_data removeObjectForKey:@"LeadSource"];
                                               [_tableView reloadData];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {}
                                              origin:cell];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CLOSE_DATE_CELL])
    {
        NSDate *date;
        NSString *dateText = ((PMTextFieldTVCell*)cell).textField.text;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if(dateText && dateText.length) date = [dateFormatter dateFromString:dateText];
        
        if(!date) date = [NSDate date];
        
        AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            
            NSString *selectedDateString = [dateFormatter stringFromDate:selectedDate];
            
            ((PMTextFieldTVCell*)cell).textField.text = selectedDateString;
            [_data setObject:selectedDateString forKey:@"CloseDate"];
            
        } cancelBlock:^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        datePickerViewController.datePicker.datePickerMode = UIDatePickerModeDate;
        [self presentViewController:datePickerViewController animated:YES completion:nil];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_OWNER_CELL])
    {
        [self.view endEditing:YES];
        PMSFUserListVC *vc = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFUserListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_ACCOUNT_CELL])
    {
        [self.view endEditing:YES];
        PMSFAccountListVC *vc = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFAccountListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CAMPAIGN_CELL])
    {
        [self.view endEditing:YES];
        PMSFCampaignListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFCampaignListVC"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark PMTextFieldTVCellDelegate
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString *)text {
    if ([textFieldTVCell.reuseIdentifier isEqualToString:@"sfOpportunityNameCell"]) {
        [_data setObject:text forKey:@"Name"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:OPPORTUNITY_AMOUNT_CELL]) {
        [_data setObject:text forKey:@"Amount"];
    }
    else if ([textFieldTVCell.reuseIdentifier isEqualToString:OPPORTUNITY_NEXT_STEP_CELL]) {
        [_data setObject:text forKey:@"NextStep"];
    }
    
}
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell getFocus:(UITextField *)textField
{
    firstResponderCell = textFieldTVCell;
}

#pragma mark PMTextViewTVCellDelegate
- (void)PMTextViewTVCellDelegate:(PMTextViewTVCell *)textViewTVCell textDidChange:(NSString *)text {
    if ([textViewTVCell.reuseIdentifier isEqualToString:OPPORTUNITY_DESCRIPTION_CELL]) {
        [_data setObject:text forKey:@"Description"];
    }
    
}
- (void)PMTextViewTVCellDelegate:(PMTextFieldTVCell *)textViewTVCell getFocus:(UITextView *)textView
{
    firstResponderCell = textViewTVCell;
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


#pragma mark PMSFCampaignListVCDelegate
-(void)campaignListVC:(PMSFAccountListVC *)vc didSelectCampaign:(NSDictionary *)data
{
    _campaignName = data[@"Name"];
    _data[@"CampaignId"] = data[@"Id"];
    
    [_tableView reloadData];
}

@end