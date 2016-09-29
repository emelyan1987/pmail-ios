//
//  PMCreateEventTVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCreateEventVC.h"
#import "PickerCells.h"
#import "PMAPIManager.h"

#import "PMTextFieldTVCell.h"
#import "PMTextViewTVCell.h"
#import "PMSwitchTVCell.h"
#import "PMLocalNotification.h"
#import "MBProgressHUD.h"
#import "UIViewController+PMStoryboard.h"
#import "PMEventAlertVC.h"
#import "PMEventInviteesVC.h"
#import "PMEventCalendarListVC.h"
#import "PMInviteesTVCell.h"
#import "AlertManager.h"
#import "PMParticipantModel.h"


#import <GoogleMaps/GoogleMaps.h>

@interface PMCreateEventVC () <UITableViewDelegate, UITableViewDataSource, PMSwitchTVCellDelegate, PMTextFieldTVCellDelegate, PMTextViewTVCellDelegate, PickerCellsDelegate, PMEventAlertVCDelegate, PMEventCalendarListVCDelegate, PMEventInviteesVCDelegate, GMSAutocompleteViewControllerDelegate> {
    NSArray *_itemArray;
    
    IBOutlet UITableView *_tableView;
    IBOutlet NSLayoutConstraint *_tableViewTop;
    IBOutlet UIView *deleteBtnView;
    IBOutlet UIButton *btnDelete;
    
    
    BOOL _isAllDay;
    
    UITableViewCell *firstResponderCell;
    DBCalendar *selectedCalendar;
    NSArray *selectedPeoples;
    
    CGFloat peopleCellHeight;
    
    
    UIDatePicker *datePicker1;
    UIDatePicker *datePicker2;
}
@property(nonatomic, strong) PickerCellsController *pickersController;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
- (IBAction)deleteBtnPressed:(id)sender;
@end

@implementation PMCreateEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isAllDay = NO;
    
    if (_eventModel == nil) {
        _eventModel = [PMEventModel new];
    }
    if(_eventModel)
        _isAllDay = _eventModel.eventDateType==EventDateDateType || _eventModel.eventDateType==EventDateDatespanType;
    
    
    
    _itemArray = @[@"eventTitleCell",
                   @[@"eventAllDayCell", @"eventStartsCell", @"eventEndsCell"],
                   @"eventInviteesCell",
                   @"eventLocationCell",
                   @[@"eventCalendarCell", @"eventAlertCell"],
                   @"eventNotesCell"];
   
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.pickersController = [PickerCellsController new];
    [self.pickersController attachToTableView:_tableView tableViewsPriorDelegate:self withDelegate:self];
    
    NSDate *from = [NSDate date];
    
    if(_eventModel && _eventModel.startTime)
    {
        if(_eventModel.eventDateType == EventDateDatespanType || _eventModel.eventDateType == EventDateDateType)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            from = [dateFormatter dateFromString:_eventModel.startTime];
        } else {
            from = [NSDate dateWithTimeIntervalSince1970:[_eventModel.startTime doubleValue]];
        }
    }
    
    NSDate *to = [from dateByAddingTimeInterval:1800];
    if(_eventModel && _eventModel.endTime)
    {
        if(_eventModel.eventDateType == EventDateDatespanType || _eventModel.eventDateType == EventDateDateType)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            to = [dateFormatter dateFromString:_eventModel.endTime];
        } else {
            to = [NSDate dateWithTimeIntervalSince1970:[_eventModel.endTime doubleValue]];
        }
    }
    
    datePicker1 = [[UIDatePicker alloc] init];
    datePicker1.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker1.date = from;
    NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.pickersController addDatePicker:datePicker1 forIndexPath:path1];
    
    datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker2.date = to;
    NSIndexPath *path2 = [NSIndexPath indexPathForRow:2 inSection:1];
    [self.pickersController addDatePicker:datePicker2 forIndexPath:path2];
    
    datePicker1.maximumDate = datePicker2.date;
    datePicker2.minimumDate = datePicker1.date;
    [datePicker1 addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    [datePicker2 addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    
    NSArray *calendars = [[DBManager instance] getWritableCalendars];
    
    if(_eventModel && _eventModel.calendarId.length>0)
    {
        DBCalendar *calendar = [DBCalendar getCalendarWithId:_eventModel.calendarId];
        selectedCalendar = calendar;
    } else {
        if(calendars.count>0) selectedCalendar = calendars[0];
    }
    
    [self performSelector:@selector(setInitPeopleData) withObject:nil afterDelay:.1];
    
    peopleCellHeight = 40;
    
    
    if(self.isUpdate) deleteBtnView.hidden = NO;
    else deleteBtnView.hidden = YES;
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
    
    deleteBtnView.layer.cornerRadius = deleteBtnView.frame.size.height/2;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInitPeopleData
{
    if(_eventModel.participants && _eventModel.participants.count>0)
    {
        NSMutableArray *participants = [NSMutableArray new];
        for(PMParticipantModel *participant in _eventModel.participants)
        {
            [participants addObject:[participant convertToDictionary]];
        }
        selectedPeoples = participants;
    } else {
        selectedPeoples = [NSArray new];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    PMInviteesTVCell *peopleCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    [peopleCell setPeoples:selectedPeoples];
    
    peopleCellHeight = [peopleCell height];
    
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private methods

- (void)keyboardDidShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //_tableViewTop.constant = -keyboardSize.height + 45;
    
    
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat newY = 0;
        CGRect superRect = self.view.frame;
        CGRect tableRect = _tableView.frame;
        CGRect cellRect = firstResponderCell.frame;
        
        CGFloat dy = superRect.size.height - keyboardSize.height - cellRect.origin.y;
        
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, dy<150?dy-150+64:64, _tableView.frame.size.width, _tableView.frame.size.height)];
        //[self.view setNeedsLayout];
    }];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    _tableViewTop.constant = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setNeedsLayout];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)createEvent {
    
    if(selectedCalendar==nil)
    {
        [AlertManager showErrorMessage:@"Please select your calendar"]; return;
    }
    
    _eventModel.calendarId = selectedCalendar.calendarId;
    _eventModel.participants = selectedPeoples;
    
    if([datePicker2.date compare:datePicker1.date] == NSOrderedAscending)
    {
        [AlertManager showErrorMessage:@"End time can't be before start time."]; return;
    }
    
    BOOL emptyInvitees = NO;
    if(selectedPeoples==nil || selectedPeoples.count==0)
    {
        emptyInvitees = YES;
    }
    
    if(_isAllDay)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        _eventModel.startTime = [dateFormatter stringFromDate:datePicker1.date];
        _eventModel.endTime = [dateFormatter stringFromDate:datePicker2.date];
        
        _eventModel.eventDateType = EventDateDatespanType;
    }
    else
    {
        _eventModel.startTime = [NSString stringWithFormat:@"%f", [datePicker1.date timeIntervalSince1970]];
        _eventModel.endTime = [NSString stringWithFormat:@"%f", [datePicker2.date timeIntervalSince1970]];
        
        _eventModel.eventDateType = EventDateTimespanType;
    }
    
    
    
    NSDictionary *lEventParams = [_eventModel getEventParams];
    
    
    NSLog(@"%@", lEventParams);
    

    [self dismissViewControllerAnimated:YES completion:^{
        NSDate *issuedTime = [NSDate date];
        [AlertManager showStatusBarWithMessage:emptyInvitees?@"Saving event...":@"Sending meeting invite..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:selectedCalendar.account_id];
        
        if(_isUpdate)
        {
            NSString *eventId = _eventModel.id;
            [[PMAPIManager shared] updateCalendarEventWithAccount:namespace eventId:eventId eventParams:lEventParams comlpetion:^(id data, id error, BOOL success) {
                [AlertManager hideStatusBar:issuedTime];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(success)
                    {
                        if (success && _eventModel.alertTime != nil) {
                            // add create notification logic
                        }
                        
                        [AlertManager showStatusBarWithMessage:emptyInvitees?@"Event saved.":@"Meeting invite sent." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_UPDATED object:nil];
                    }
                    else
                    {
                        [AlertManager showStatusBarWithMessage:emptyInvitees?@"Saving event faild":@"Meeting invite failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
                    }
                });
            }];
        }
        else
        {
            [[PMAPIManager shared] createCalendarEventWithAccount:namespace eventParams:lEventParams comlpetion:^(id data, id error, BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AlertManager hideStatusBar:issuedTime];
                    
                    if(success)
                    {
                        if (success && _eventModel.alertTime != nil) {
                            // add create notification logic
                        }
                        [AlertManager showStatusBarWithMessage:emptyInvitees?@"Event saved.":@"Meeting invite sent." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                        
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_UPDATED object:nil];
                    }
                    else
                    {
                        [AlertManager showStatusBarWithMessage:emptyInvitees?@"Saving event faild":@"Meeting invite failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
                    }
                    
                });
            }];
        }
    }];
}

#pragma mark - IBAction selectors

- (void)cancelBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBtnPressed:(id)sender {
    [self createEvent];
}

- (IBAction)deleteBtnPressed:(id)sender
{
    NSLog(@"deleteBtnPressed");
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDelete = [UIAlertAction
                                   actionWithTitle:@"Delete Event"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                       DBCalendar *calendar = [_eventModel getCalendar];
                                       DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:calendar.account_id];
                                       [[PMAPIManager shared] deleteCalendarEventWithAccount:namespace eventId:_eventModel.id eventParams:nil comlpetion:^(id data, id error, BOOL success) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_UPDATED object:nil];
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }];
                                   }];
    
    
    UIAlertAction *actionCancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    [alert addAction:actionDelete];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger lCountRows = 0;
    id lItem = _itemArray.count > 0 ? _itemArray[section] : nil;
    if (lItem) {
        lCountRows = [lItem isKindOfClass:[NSArray class]] ? ((NSArray*)lItem).count : 1;
    }
    return lCountRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _itemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lEstimateHeight = 40;
    
    if(indexPath.section == 2)
    {
        lEstimateHeight = peopleCellHeight;
    }
    
    if (_itemArray.count - 1 == indexPath.section) {
        lEstimateHeight = 300;
    }
    return lEstimateHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *lCellIdentifier = nil;
    id lItem = _itemArray[indexPath.section];
    if ([lItem isKindOfClass:[NSArray class]]) {
        lCellIdentifier = ((NSArray*)lItem)[indexPath.row];
    } else {
        lCellIdentifier = lItem;
    }
    
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:lCellIdentifier];
    
    id picker = [self.pickersController pickerForOwnerCellIndexPath:indexPath];
    if (picker) {
        if ([picker isKindOfClass:UIPickerView.class]) {
            
            UIPickerView *pickerView = (UIPickerView *)picker;
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
            NSString *title = [self pickerView:pickerView titleForRow:selectedRow forComponent:0];
            lCell.detailTextLabel.text = title;
            
        } else if ([picker isKindOfClass:UIDatePicker.class]) {
            
            UIDatePicker *datePicker = (UIDatePicker *)picker;
            datePicker.datePickerMode = _isAllDay?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //if (datePicker.datePickerMode == UIDatePickerModeDateAndTime) {
                [dateFormatter setDateFormat:_isAllDay ? @"dd MMM. yyyy" : @"dd MMM. yyyy HH:mm"];
            //}
            lCell.detailTextLabel.text = [dateFormatter stringFromDate:[(UIDatePicker *)picker date]];
            
//            if ([lCell.reuseIdentifier isEqualToString:@"eventStartsCell"]) {
//                _eventModel.startTime = [dateFormatter stringFromDate:[(UIDatePicker *)picker date]];
//                
//            } else if ([lCell.reuseIdentifier isEqualToString:@"eventEndsCell"]) {
//                _eventModel.endTime = [dateFormatter stringFromDate:[(UIDatePicker *)picker date]];
//            }
            
        }
    }
    
    if ([lCell.reuseIdentifier isEqualToString:@"eventTitleCell"])
    {
        [((PMTextFieldTVCell*)lCell) setDelegate:self];
        ((PMTextFieldTVCell*)lCell).textField.text = _eventModel.title;
    }
    else if([lCell.reuseIdentifier isEqualToString:@"eventLocationCell"])
    {
        [((PMTextFieldTVCell*)lCell) setDelegate:self];
        ((PMTextFieldTVCell*)lCell).textField.text = _eventModel.location;
    }
    else if([lCell.reuseIdentifier isEqualToString:@"eventNotesCell"])
    {
        [((PMTextViewTVCell*)lCell) setDelegate:self];
        ((PMTextViewTVCell*)lCell).textView.text = _eventModel.eventDescription;
    }
    else if ([lCell.reuseIdentifier isEqualToString:@"eventAllDayCell"])
    {
        [((PMSwitchTVCell*)lCell) setDelegate:self];
        ((PMSwitchTVCell*)lCell).switchCtrl.on = _isAllDay;
    }
    else if ([lCell.reuseIdentifier isEqualToString:@"eventAlertCell"])
    {
        lCell.detailTextLabel.text = _eventModel.alertMessage;
    }
    else if ([lCell.reuseIdentifier isEqualToString:@"eventCalendarCell"])
    {
        lCell.detailTextLabel.text = selectedCalendar?selectedCalendar.name:@"Select Calendar";
    }
    else if ([lCell.reuseIdentifier isEqualToString:@"eventInviteesCell"])
    {
        [((PMInviteesTVCell*)lCell) setPeoples:selectedPeoples];
    }
    
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *lCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([lCell.reuseIdentifier isEqualToString:@"eventAlertCell"]) {
        
        PMEventAlertVC *lEventAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventAlertVC"];
        [lEventAlertVC setDelegate:self];
        if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
            [self.navigationController pushViewController:lEventAlertVC animated:YES];
        }
        
    } else if ([lCell.reuseIdentifier isEqualToString:@"eventInviteesCell"]) {
        
        PMEventInviteesVC *lEventInviteesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventInviteesVC"];
        lEventInviteesVC.delegate = self;
        if(selectedPeoples && selectedPeoples.count)
            lEventInviteesVC.peoples = [NSMutableArray arrayWithArray:selectedPeoples];
        if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
            [self.navigationController pushViewController:lEventInviteesVC animated:YES];
        }
    } else if ([lCell.reuseIdentifier isEqualToString:@"eventCalendarCell"]) {
        
        PMEventCalendarListVC *lEventCalendarListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventCalendarListVC"];
        lEventCalendarListVC.delegate = self;
        lEventCalendarListVC.selectedCalendar = selectedCalendar;
        if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
            [self.navigationController pushViewController:lEventCalendarListVC animated:YES];
        }
    } else if ([lCell.reuseIdentifier isEqualToString:@"eventLocationCell"]) {
        
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        
        acController.tintColor = [UIColor whiteColor];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *text = [NSString stringWithFormat:@"Row number %li", (long)row];
    return text;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSIndexPath *ip = [self.pickersController indexPathForPicker:pickerView];
    if (ip) {
        [_tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - PickerCells delegate

- (void)pickerCellsController:(PickerCellsController *)controller willExpandTableViewContent:(UITableView *)tableView forHeight:(CGFloat)expandHeight {
    NSLog(@"expand height = %.f", expandHeight);
}

- (void)pickerCellsController:(PickerCellsController *)controller willCollapseTableViewContent:(UITableView *)tableView forHeight:(CGFloat)expandHeight {
    NSLog(@"collapse height = %.f", expandHeight);
}

#pragma mark - Actions

- (void)dateSelected:(UIDatePicker *)sender {
    NSIndexPath *indexPath = [self.pickersController indexPathForPicker:sender];
    if (indexPath) {
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    datePicker1.maximumDate = datePicker2.date;
    datePicker2.minimumDate = datePicker1.date;
    
}

#pragma mark - PMTextFieldTVCell delegates

- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString *)text {
    if ([textFieldTVCell.reuseIdentifier isEqualToString:@"eventTitleCell"]) {
        _eventModel.title = text;
    } else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"eventLocationCell"]) {
        _eventModel.location = text;
    }
}
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell getFocus:(UITextField *)textField
{
    firstResponderCell = textFieldTVCell;
}

#pragma mark - PMTextViewTVCell delegates

-(void)PMTextViewTVCellDelegate:(PMTextViewTVCell *)textViewCell getFocus:(UITextView *)textView
{
    firstResponderCell = textViewCell;
}
-(void)PMTextViewTVCellDelegate:(PMTextViewTVCell *)textViewCell textDidChange:(NSString *)text
{
    if([textViewCell.reuseIdentifier isEqualToString:@"eventNotesCell"]) {
        _eventModel.eventDescription = text;
    }
}
#pragma mark - PMSwitchTVCell delegates

- (void)PMSwitchTVCell:(PMSwitchTVCell *)switchTVCell stateDidChange:(BOOL)state {
    _isAllDay = state;
    [_tableView reloadData];
}

#pragma mark - PMEventAlertVC delegates

- (void)PMEventAlertVCDelegate:(PMEventAlertVC *)eventAlertVC alertTimeDidChange:(NSDate *)date message:(NSString *)message {
    _eventModel.alertMessage = message;
    [_tableView reloadData];
}

#pragma mark - PMEventCalendarListVCDelegate

-(void)didSelectCalendar:(DBCalendar *)calendar
{
    selectedCalendar = calendar;
    [_tableView reloadData];
}

#pragma mark - PMEventInviteesVCDelegate
-(void)didSelectPeoples:(NSArray *)peoples
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    PMInviteesTVCell *peopleCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    selectedPeoples = peoples;
    [peopleCell setPeoples:selectedPeoples];
    
    peopleCellHeight = [peopleCell height];
    
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - GMSAutocompleteViewControllerDelegate
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    _eventModel.location = place.name;
    [_tableView reloadData];

}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
