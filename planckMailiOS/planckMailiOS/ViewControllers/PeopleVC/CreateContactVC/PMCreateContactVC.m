//
//  PMCreateContactVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMCreateContactVC.h"
#import "Config.h"
#import "PMPhoneInputCell.h"
#import "PMPhoneAddCell.h"
#import "PMEmailInputCell.h"
#import "PMEmailAddCell.h"
#import "ActionSheetStringPicker.h"
#import "AIDatePickerController.h"
#import "AlertManager.h"
#import "PMTextManager.h"

#define ROW_HEIGHT 41

@interface PMCreateContactVC ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (weak, nonatomic) IBOutlet UITableView *phoneTableView;
@property (weak, nonatomic) IBOutlet UITableView *emailTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTableViewHeightConstraint;

@property (nonatomic, strong) NSMutableDictionary *deleteConfirmStatusForPhoneCell;
@property (nonatomic, strong) NSMutableDictionary *deleteConfirmStatusForEmailCell;

@property (nonatomic, assign) NSInteger keyboardHeight;
@property (nonatomic, strong) UITapGestureRecognizer *recognizerForKeyboardDismiss;
@property (nonatomic, strong) UITapGestureRecognizer *recognizerForProfileSelection;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerOnPhoneTableView;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerOnEmailTableView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableDictionary *contactData;
@end

@implementation PMCreateContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(_data) [self.navigationBar.topItem setTitle:@"Edit Contact"];
    else [self.navigationBar.topItem setTitle:@"Create Contact"];
    
    _keyboardHeight = 0;
    
    DLog(@"PMCreateContactVC ContactData:%@", _data);
    
    if(_data) _contactData = [NSMutableDictionary dictionaryWithDictionary:_data];
    else _contactData = [NSMutableDictionary new];
    
    _deleteConfirmStatusForPhoneCell = [NSMutableDictionary new];
    _deleteConfirmStatusForEmailCell = [NSMutableDictionary new];
    
    
    // Add right swipe gesture recognizer for undoing delete confirm of phone cell.
    _recognizerOnPhoneTableView = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeRightOnPhoneTableView:)];
    [_recognizerOnPhoneTableView setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_phoneTableView addGestureRecognizer:_recognizerOnPhoneTableView];
    
    // Add right swipe gesture recognizer for undoing delete confirm of email cell.
    _recognizerOnEmailTableView = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleSwipeRightOnEmailTableView:)];
    [_recognizerOnEmailTableView setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_emailTableView addGestureRecognizer:_recognizerOnEmailTableView];
    
    
    // Add tap gesture recognizer for dismissing keyboard when touch other places.
    _recognizerForKeyboardDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _recognizerForKeyboardDismiss.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_recognizerForKeyboardDismiss];
    
    
    // Add tap gesture recognizer for selecting profile image.
    _recognizerForProfileSelection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTap:)];
    _recognizerForProfileSelection.cancelsTouchesInView = NO;
    [_profileView addGestureRecognizer:_recognizerForProfileSelection];
    
    
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
    _profileImageView.clipsToBounds = YES;
    
    _nameTextField.delegate = self;
    _companyTextField.delegate = self;
    _jobTextField.delegate = self;
    _addressTextField.delegate = self;
    
    _nameTextField.text = _contactData[@"name"];
    _companyTextField.text = _contactData[@"company"];
    _jobTextField.text = _contactData[@"job"];
    _addressTextField.text = _contactData[@"address"];
    
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM dd, YYYY"];
    
    NSDate *birthday = _contactData[@"birthday"];
    if(birthday)
    {
        _birthdayTextField.text = [_dateFormatter stringFromDate:birthday];
    }
    
    NSData *profileData = _contactData[@"profile_data"];
    if(profileData)
    {
        UIImage *profileImage = [UIImage imageWithData:profileData];
        _profileImageView.image = profileImage;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *phoneNumbers = _contactData[@"phone_numbers"];
    _phoneTableViewHeightConstraint.constant = (phoneNumbers.count+1)*ROW_HEIGHT;
    
    NSArray *emails = _contactData[@"emails"];
    _emailTableViewHeightConstraint.constant = (emails.count+1)*ROW_HEIGHT;
    
    [self.view layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    _keyboardHeight = 0;
}

- (void)viewDidLayoutSubviews
{
    CGSize contentSize = _scrollView.contentSize;
    _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentSize.height+_keyboardHeight+100);
    
}

- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnDoneClicked:(id)sender {
    //NSLog(@"Inputted contact info = %@", _contactData);
    
    if(![self validateContactData:_contactData])
    {
        return;
    }
    else
    {
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        DBSavedContact *savedContact = [DBSavedContact createOrUpdateContactWithData:_contactData onContext:context];
        [[DBManager instance] saveOnContext:context];
        
        DLog(@"Saved Contact Identifier: %@,%@,%@", savedContact.id, savedContact.name, savedContact.emails);
        
        if([self.delegate respondsToSelector:@selector(didSaveContact:)])
        {
            DLog(@"DidSaveContactWithData:%@,%@", savedContact.name, savedContact.emails);
            [self.delegate didSaveContact:savedContact];
        }
        
        [self performSelector:@selector(sendNotification:) withObject:NOTIFICATION_CONTACT_DATA_CHANGED afterDelay:3];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)sendNotification:(NSString*)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}
-(BOOL)validateContactData:(NSDictionary*)data
{
    if(!data[@"name"] || ((NSString*)data[@"name"]).length==0)
    {
        [AlertManager showErrorMessage:@"Contact name is required."];
        [_nameTextField becomeFirstResponder];
        return NO;
    }
    /*if(!data[@"emails"] || ((NSArray*)data[@"emails"]).count==0)
    {
        [AlertManager showErrorMessage:@"Contact emails are required."];
        return NO;
    }*/
    
    for(NSString *email in data[@"emails"])
    {
        if (![[PMTextManager shared] isValidEmail:email])
        {
            [AlertManager showErrorMessage:[NSString stringWithFormat:@"The \"%@\" is invalid email address format.", email]];
            return NO;
        }
        
        
        DBSavedContact *contactWithEmail = [DBSavedContact getContactWithEmail:email];
        if(contactWithEmail)
        {
            if(_contactData)
            {
                if(![_contactData[@"id"] isEqualToString:contactWithEmail.id])
                {
                    [AlertManager showErrorMessage:[NSString stringWithFormat:@"The \"%@\" have been added already", email]];
                    return NO;
                }
            }
            else
            {
                [AlertManager showErrorMessage:[NSString stringWithFormat:@"The \"%@\" have been added already", email]];
                return NO;
            }
            
        }
    }
    
    return YES;
}
#pragma UITableViewDataSource & UITableViewDelegate implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:_phoneTableView])
    {
        if(_contactData && _contactData[@"phone_numbers"])
        {
            NSArray *phoneNumbers = _contactData[@"phone_numbers"];
            return phoneNumbers.count+1;
        }
        else
        {
            return 1;
        }
    }
    else if([tableView isEqual:_emailTableView])
    {
        if(_contactData && _contactData[@"emails"])
        {
            NSArray *emails = _contactData[@"emails"];
            return emails.count+1;
        }
        else
        {
            return 1;
        }
    }
    
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:_phoneTableView])
    {
        if(indexPath.row == [tableView numberOfRowsInSection:0]-1)
        {
            PMPhoneAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneAddCell"];
            
            cell.addButtonTapAction = ^(id sender){
                NSMutableArray *phoneNumbers = _contactData[@"phone_numbers"]?[NSMutableArray arrayWithArray:_contactData[@"phone_numbers"]]:[NSMutableArray new];
                [phoneNumbers addObject:[NSMutableDictionary dictionaryWithDictionary:@{kPhoneTitle:[self getLastPhoneTitle], kPhoneNumber:@""}]];
                
                [_contactData setObject:phoneNumbers forKey:@"phone_numbers"];
                
                _phoneTableViewHeightConstraint.constant = ROW_HEIGHT * (phoneNumbers.count+1);
                [self.view layoutIfNeeded];
                
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForItem:[tableView numberOfRowsInSection:0]-1 inSection:0];
                NSArray *insertIndexPaths = @[insertIndexPath];
                [_phoneTableView beginUpdates];

                [_phoneTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_phoneTableView endUpdates];
                
                PMPhoneInputCell *insertedCell = [_phoneTableView cellForRowAtIndexPath:insertIndexPath];
                [insertedCell.textField becomeFirstResponder];
                
            };
            return cell;
        }
        else
        {
            PMPhoneInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneInputCell"];
            
            NSDictionary *phoneNumber = _contactData[@"phone_numbers"][indexPath.row];
            BOOL deleteConfirmStatus = [_deleteConfirmStatusForPhoneCell objectForKey:indexPath]?[[_deleteConfirmStatusForPhoneCell objectForKey:indexPath] boolValue]:NO;
            [cell bindData:phoneNumber deleteConfirmStatus:deleteConfirmStatus];
            
            __weak PMPhoneInputCell *_weakCell = cell;
            
            cell.textFieldDidChange = ^(id sender, NSString *text) {
                [_contactData[@"phone_numbers"][indexPath.row] setObject:text forKey:kPhoneNumber];
            };
            
            cell.btnTitleTapAction = ^(id sender)
            {
                [self.view endEditing:YES];
                [ActionSheetStringPicker showPickerWithTitle:nil rows:PHONE_TITLES initialSelection:[PHONE_TITLES indexOfObject:phoneNumber[@"phone_title"]] doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                    
                    NSInteger index = indexPath.row;
                    [_contactData[@"phone_numbers"][index] setObject:selectedValue forKey:kPhoneTitle];
                    
                    [_phoneTableView reloadData];
                } cancelBlock:^(ActionSheetStringPicker *picker) {
                    
                } origin:_weakCell.btnTitle];
            };
            
            
            cell.btnDeleteTapAction = ^(id sender) {
                [_weakCell layoutIfNeeded];
                _weakCell.contentViewLeadingConstraint.constant = -72;
                [UIView animateWithDuration:0.3 animations:^{
                    [_weakCell layoutIfNeeded];
                    
                    [_deleteConfirmStatusForPhoneCell setObject:@(YES) forKey:indexPath];
                }];
            };
            
            cell.btnDeleteConfirmTapAction = ^(id sender) {
                
                NSInteger index = indexPath.row;                
                [_phoneTableView beginUpdates];
                [_contactData[@"phone_numbers"] removeObjectAtIndex:index];
                [_phoneTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [_phoneTableView endUpdates];
                
                [_deleteConfirmStatusForPhoneCell setObject:@(NO) forKey:indexPath];
                
                _phoneTableViewHeightConstraint.constant = ROW_HEIGHT * (((NSArray*)_contactData[@"phone_numbers"]).count+1);
                [self.view layoutIfNeeded];
                [_phoneTableView reloadData];
            };
            
            
            return cell;
        }
    }
    else if([tableView isEqual:_emailTableView])
    {
        if(indexPath.row == [tableView numberOfRowsInSection:0]-1)
        {
            PMEmailAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emailAddCell"];
            
            cell.addButtonTapAction = ^(id sender){
                NSMutableArray *emails = _contactData[@"emails"]?[NSMutableArray arrayWithArray:_contactData[@"emails"]]:[NSMutableArray new];
                [emails addObject:@""];
                
                [_contactData setObject:emails forKey:@"emails"];
                
                _emailTableViewHeightConstraint.constant = ROW_HEIGHT * (emails.count+1);
                [self.view layoutIfNeeded];
                
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForItem:[tableView numberOfRowsInSection:0]-1 inSection:0];
                NSArray *insertIndexPaths = @[insertIndexPath];
                [_emailTableView beginUpdates];
                
                [_emailTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_emailTableView endUpdates];
                
                PMEmailInputCell *insertedCell = [_emailTableView cellForRowAtIndexPath:insertIndexPath];
                [insertedCell.textField becomeFirstResponder];
                
            };
            return cell;
        }
        else
        {
            PMEmailInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emailInputCell"];
            
            NSDictionary *emailData = @{@"email":_contactData[@"emails"][indexPath.row]};
            BOOL deleteConfirmStatus = [_deleteConfirmStatusForEmailCell objectForKey:indexPath]?[[_deleteConfirmStatusForEmailCell objectForKey:indexPath] boolValue]:NO;
            [cell bindData:emailData deleteConfirmStatus:deleteConfirmStatus];
            
            __weak PMEmailInputCell *_weakCell = cell;
            
            cell.textFieldDidChange = ^(id sender, NSString *text) {
                [_contactData[@"emails"] replaceObjectAtIndex:indexPath.row withObject:text];
            };
            
            
            cell.btnDeleteTapAction = ^(id sender) {
                [_weakCell layoutIfNeeded];
                _weakCell.contentViewLeadingConstraint.constant = -72;
                [UIView animateWithDuration:0.3 animations:^{
                    [_weakCell layoutIfNeeded];
                    
                    [_deleteConfirmStatusForEmailCell setObject:@(YES) forKey:indexPath];
                }];
            };
            
            cell.btnDeleteConfirmTapAction = ^(id sender) {
                
                NSInteger index = indexPath.row;
                [_emailTableView beginUpdates];
                [_contactData[@"emails"] removeObjectAtIndex:index];
                [_emailTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [_emailTableView endUpdates];
                
                [_deleteConfirmStatusForEmailCell setObject:@(NO) forKey:indexPath];
                
                _emailTableViewHeightConstraint.constant = ROW_HEIGHT * (((NSArray*)_contactData[@"emails"]).count+1);
                [self.view layoutIfNeeded];
                [_emailTableView reloadData];
            };
            
            
            return cell;
        }
    }
    
    return nil;
}


- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}


- (void)handleProfileTap:(UITapGestureRecognizer *) sender
{
    //[self.view endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"From Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            [AlertManager showErrorMessage:@"No support camera function!"];
            return;
            
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:actionPhoto];
    [alert addAction:actionCamera];
    [alert addAction:actionCancel];
    
    alert.popoverPresentationController.sourceView = _profileView;
    alert.popoverPresentationController.sourceRect = _profileView.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleSwipeRightOnPhoneTableView:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_phoneTableView];
    NSIndexPath *indexPath = [_phoneTableView indexPathForRowAtPoint:location];
    
    BOOL deleteConfirmStatus = [_deleteConfirmStatusForPhoneCell objectForKey:indexPath] ? [[_deleteConfirmStatusForPhoneCell objectForKey:indexPath] boolValue] : NO;
    
    if(deleteConfirmStatus)
    {
        PMPhoneInputCell *cell = [_phoneTableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        cell.contentViewLeadingConstraint.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [cell layoutIfNeeded];
            
            [_deleteConfirmStatusForPhoneCell setObject:@(NO) forKey:indexPath];
        }];
    }
    
}

- (void)handleSwipeRightOnEmailTableView:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_emailTableView];
    NSIndexPath *indexPath = [_emailTableView indexPathForRowAtPoint:location];
    
    BOOL deleteConfirmStatus = [_deleteConfirmStatusForEmailCell objectForKey:indexPath] ? [[_deleteConfirmStatusForEmailCell objectForKey:indexPath] boolValue] : NO;
    
    if(deleteConfirmStatus)
    {
        PMEmailInputCell *cell = [_emailTableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        cell.contentViewLeadingConstraint.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [cell layoutIfNeeded];
            
            [_deleteConfirmStatusForEmailCell setObject:@(NO) forKey:indexPath];
        }];
    }
    
}
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([tableView isEqual:self.phoneTableView])
    {
        
    }
}

-(NSString*)getLastPhoneTitle
{
    NSString *title;
    
    NSArray *phoneNumbers = _contactData[@"phone_numbers"];
    
    NSMutableArray *phoneTitles = [NSMutableArray new];
    for(NSDictionary *phoneNumber in phoneNumbers)
    {
        [phoneTitles addObject:phoneNumber[@"phone_title"]];
    }
    for(NSString *phoneTitle in PHONE_TITLES)
    {
        if(![phoneTitles containsObject:phoneTitle])
        {
            title = phoneTitle; return title;
        }
    }
    
    return PHONE_TITLES[0];
}

- (IBAction)btnBirthdaySelectClicked:(id)sender {
    
    NSDate *date;
    NSString *birthdayText = _birthdayTextField.text;
    if(birthdayText && birthdayText.length) date = [_dateFormatter dateFromString:birthdayText];
    
    if(!date) date = [NSDate date];
    
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        
        [_contactData setObject:selectedDate forKey:@"birthday"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        NSString *selectedDateString = [_dateFormatter stringFromDate:selectedDate];
        
        _birthdayTextField.text = selectedDateString;
    } cancelBlock:^{
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    datePickerViewController.datePicker.datePickerMode = UIDatePickerModeDate;
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

#pragma UITextFieldDelegate implementation

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if([textField isEqual:_nameTextField])
        [_contactData setObject:text forKey:@"name"];
    else if([textField isEqual:_companyTextField])
        [_contactData setObject:text forKey:@"company"];
    else if([textField isEqual:_jobTextField])
        [_contactData setObject:text forKey:@"job"];
    else if([textField isEqual:_addressTextField])
        [_contactData setObject:text forKey:@"address"];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma UIImagePickerControllerDelegate implementation
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _profileImageView.image = chosenImage;
    
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    [_contactData setObject:imageData forKey:@"profile_data"];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
