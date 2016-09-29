//
//  PMMailComposeEventVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeEventVC.h"
#import "PMAPIManager.h"

#import "PMTextFieldTVCell.h"
#import "UIViewController+PMStoryboard.h"
#import "PMMailComposeEventDurationVC.h"
#import "PMEventAlertVC.h"
#import "PMEventInviteesVC.h"
#import "PMInviteesTVCell.h"
#import "AlertManager.h"
#import "PMParticipantModel.h"
#import "AIDatePickerController.h"

#import <GoogleMaps/GoogleMaps.h>

@interface PMMailComposeEventVC () <UITableViewDelegate, UITableViewDataSource, PMTextFieldTVCellDelegate,  PMEventInviteesVCDelegate, GMSAutocompleteViewControllerDelegate, PMMailComposeEventDurationVCDelegate>
{
    NSArray *_itemArray;
    UITableViewCell *_firstResponderCell;
    NSArray *_selectedPeoples;
    NSInteger _duration;
    
    CGFloat _peopleCellHeight;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
@end

@implementation PMMailComposeEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemArray = @[@"eventTitleCell",
                   @"eventDurationCell",
                   @"eventLocationCell",
                   @"eventInviteesCell"];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    
    
    
    if(_eventModel==nil) _eventModel = [[PMMailEventModel alloc] init];
    
    
    
    _peopleCellHeight = 40;
    [self performSelector:@selector(setInitPeopleData) withObject:nil afterDelay:.1];
    
    
    _duration = 30; //30 mins
    _eventModel.duration = _duration;
}

- (void)setInitPeopleData
{
    if(_eventModel.participants && _eventModel.participants.count>0)
    {
        _selectedPeoples = _eventModel.participants;
    } else {
        _selectedPeoples = [NSArray new];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    PMInviteesTVCell *peopleCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    [peopleCell setPeoples:_selectedPeoples];
    
    _peopleCellHeight = [peopleCell height];
    
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //_tableViewTop.constant = -keyboardSize.height + 45;
    
    
    [UIView animateWithDuration:0.25f animations:^{
        CGRect superRect = self.view.frame;
        CGRect cellRect = _firstResponderCell.frame;
        
        CGFloat dy = superRect.size.height - keyboardSize.height - cellRect.origin.y;
        
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, dy<150?dy-150+64:64, _tableView.frame.size.width, _tableView.frame.size.height)];
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



#pragma mark - IBAction selectors

- (void)cancelBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(didCancelEditEvent)])
        [self.delegate didCancelEditEvent];
}

- (void)doneBtnPressed:(id)sender {
//    if(_selectedPeoples==nil || _selectedPeoples.count==0)
//    {
//        [AlertManager showErrorMessage:@"Please select your invitees"]; return;
//    }
    
    
    if(!_eventModel.title || _eventModel.title.length==0) _eventModel.title = @"Title";
    _eventModel.participants = _selectedPeoples;
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(didDoneEditEvent:)])
        [self.delegate didDoneEditEvent:_eventModel];
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
    
    if(indexPath.section == 3)
    {
        lEstimateHeight = _peopleCellHeight;
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
    else if ([lCell.reuseIdentifier isEqualToString:@"eventDurationCell"])
    {
        lCell.detailTextLabel.text = [_eventModel getDurationText];
    }
    else if ([lCell.reuseIdentifier isEqualToString:@"eventInviteesCell"])
    {
        [((PMInviteesTVCell*)lCell) setPeoples:_selectedPeoples];
    }
    
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *lCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([lCell.reuseIdentifier isEqualToString:@"eventDurationCell"]) {
        
        PMMailComposeEventDurationVC *lEventDurationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeEventDurationVC"];
        [lEventDurationVC setDelegate:self];
        if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
            [self.navigationController pushViewController:lEventDurationVC animated:YES];
        }
        
    } else if ([lCell.reuseIdentifier isEqualToString:@"eventInviteesCell"]) {
        
        PMEventInviteesVC *lEventInviteesVC = [CALENDAR_STORYBOARD instantiateViewControllerWithIdentifier:@"PMEventInviteesVC"];
        lEventInviteesVC.peoples = _selectedPeoples;
        lEventInviteesVC.delegate = self;
        if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
            [self.navigationController pushViewController:lEventInviteesVC animated:YES];
        }
    } else if ([lCell.reuseIdentifier isEqualToString:@"eventLocationCell"]) {
        
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
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
    _firstResponderCell = textFieldTVCell;
}



#pragma mark - PMMailComposeEventDurationVC delegates

- (void)eventDurationVC:(PMMailComposeEventDurationVC *)eventDurationVC didSelectDuration:(NSInteger)duration
{
    _duration = duration;
    _eventModel.duration = duration;
    
    
    [_tableView reloadData];
}



#pragma mark - PMEventInviteesVCDelegate
-(void)didSelectPeoples:(NSArray *)peoples
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    PMInviteesTVCell *peopleCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    _selectedPeoples = peoples;
    [peopleCell setPeoples:_selectedPeoples];
    
    _peopleCellHeight = [peopleCell height];
    
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
    
    _eventModel.location = place.formattedAddress;
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
