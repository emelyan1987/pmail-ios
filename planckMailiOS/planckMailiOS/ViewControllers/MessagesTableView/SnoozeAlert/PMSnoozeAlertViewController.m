//
//  PMSnoozeAlertViewController.m
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import "PMSnoozeAlertViewController.h"
#import "PMAlertCollectionViewCell.h"
#import "PMAPIManager.h"#import "DBThread.h"
#import "DBManager.h"
#import "DBNamespace.h"
#import "MBProgressHUD.h"
#import "PMPickerViewController.h"
#import "NSDate+CupertinoYankee.h"
#import "Config.h"
#import "PMNotificationManager.h"
#import "PMSnoozeDateConfirmationViewController.h"
#import "AlertManager.h"
#import "KGModal.h"
#import "PMScheduleManager.h"
#import "PMFolderManager.h"
#import "AlertManager.h"

@interface PMSnoozeAlertViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, PMPickerViewControllerDelegate, PMSnoozeDateConfirmationControllerDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, weak) DBNamespace *namespace;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, assign) ScheduleDateType selectedSnoozeType;
@property (nonatomic, weak) NSDate *snoozeDate;
@property (nonatomic) NSInteger autoAsk;
@end

@implementation PMSnoozeAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self configureIconsForCollectionView];
    [self configureLabelsForCollectionView];
    [self confrigurCollectionView];
    [self configureBlurEffect];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (BOOL)isMailInFollowUp {
    
    DBNamespace *namespace = [PMAPIManager shared].namespaceId;
    
    
    NSString *scheduledFolderId = [[PMFolderManager sharedInstance] getScheduledFolderIdForAccount:namespace.namespace_id];
    
    NSArray *folders = _inboxMailModel.folders;
    BOOL isMailInFollowUp = NO;
    for(NSDictionary *folder in folders) {
        if([folder[@"id"] isEqualToString:scheduledFolderId]) {
            isMailInFollowUp = YES;
            break;
        }
    }
    if(isMailInFollowUp) {
        [self dismissOnTapAction:nil];
        return YES;
    }
    
    if ([scheduledFolderId length] == 0) {
        __weak typeof(self)__self = self;
        [[PMAPIManager shared] createFolderWithName:SCHEDULED_FOLDER_NAME account:namespace comlpetion:^(id data, id error, BOOL success) {
            
            if (!error) {
                NSDictionary *dict = (NSDictionary*)data;
                DLog(@"dict = %@", dict);
                NSString *scheduledID = dict[@"id"];
                
            } else {
                DLog(@"error = %@", error);
            }
            [MBProgressHUD hideAllHUDsForView:__self.view animated:YES];
        }];
    }
    return NO;
}

#pragma mark - Configuring UI Elements

-(void)configureIconsForCollectionView {

    self.iconsArray = @[[UIImage imageNamed:@"snooze_1.png"], [UIImage imageNamed:@"snooze_2.png"], [UIImage imageNamed:@"snooze_3.png"], [UIImage imageNamed:@"snooze_4.png"], [UIImage imageNamed:@"snooze_5.png"], [UIImage imageNamed:@"snooze_6.png"], [UIImage imageNamed:@"snooze_7.png"], [UIImage new], [UIImage new]];
    
}

-(void)configureLabelsForCollectionView {

    self.titlesArray = @[@"Later Today", @"This Evening", @"Tomorrow", @"This Weekend", @"Next Week", @"In a Month", @"Someday", @"", @"Pick a Date"];
}

-(void)configureDatePicker {
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 20, 200)];
    self.datePicker.backgroundColor = [UIColor whiteColor];
}

-(void)configureBlurEffect {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    self.blurEffectView.frame = [UIScreen mainScreen].bounds;
    
}

-(void)confrigurCollectionView {
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    UINib *nib = [UINib nibWithNibName:@"PMAlertCollectionViewCell" bundle:nil];
    [self.collectionView registerClass:[PMAlertCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
    
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.titlesArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PMAlertCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = self.iconsArray[indexPath.row];
    cell.titleLabel.text = self.titlesArray[indexPath.row];
    
    [cell.backgroungView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.backgroungView.layer setBorderWidth:1];
    cell.backgroungView.layer.masksToBounds = YES;
    cell.backgroungView.layer.cornerRadius = cell.backgroungView.frame.size.height / 2;
    
    if (indexPath.row == 7) {
        
        [cell.backgroungView removeFromSuperview];
        
    } else if (indexPath.row == 8) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 80, 80)];
        label.textColor = [UIColor colorWithRed: 51.f/255.f green: 201.f/255.f blue: 180.f/255.f alpha:1.0];
        label.text = @"08";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:45];
        [cell.backgroungView addSubview:label];
        
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self isMailInFollowUp]) {
        return;
    }
    
    PMSnoozeDateConfirmationViewController *dateConfirmationVC = [[PMSnoozeDateConfirmationViewController alloc] init];
    
    dateConfirmationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    dateConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    dateConfirmationVC.view.backgroundColor = [UIColor clearColor];
    [dateConfirmationVC setFrom:self.inboxMailModel.ownerName];
    [dateConfirmationVC setSubject:self.inboxMailModel.subject];
    dateConfirmationVC.delegate = self;
    dateConfirmationVC.isNotifyMe = self.isNotifyMe;
    
    NSDate *snoozeDate;
    
    switch (indexPath.row) {
            
        case 0: {
            snoozeDate = [[NSDate date] dateByAddingTimeInterval:60*60*3];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = LaterToday;
            
        }
            break;
            
        case 1: {
            snoozeDate = [[[NSDate date] endOfDay] dateByAddingTimeInterval:-60*60*6];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = ThisEvening;

        }
            break;
            
        case 2: {
            snoozeDate = [[[NSDate date] endOfDay] dateByAddingTimeInterval:60*60*9];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = Tomorrow;
        }
            
            break;
            
        case 3: {
            snoozeDate = [[[[NSDate date] nextSaturday] beginningOfDay] dateByAddingTimeInterval:60*60*9];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = ThisWeekend;
        }
            
            break;
            
        case 4: {
            snoozeDate = [[[[NSDate date] nextMonday] beginningOfDay] dateByAddingTimeInterval:60*60*9];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = NextWeek;
        }
            
            break;
            
        case 5: {
            snoozeDate = [[[[NSDate date] dateByAddingTimeInterval:60*60*24*30] beginningOfDay] dateByAddingTimeInterval:60*60*9];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = InAMonth;
        }
            
            break;
            
        case 6: {
            snoozeDate = [[[NSDate date] endOfDay] dateByAddingTimeInterval:60*60*8];
            [dateConfirmationVC setDate:snoozeDate];
            _selectedSnoozeType = Someday;
        }
            
            break;
        case 7:
            [self dismissOnTapAction:nil];
            
            break;
        case 8: {
            PMPickerViewController *alert = [[PMPickerViewController alloc] init];
            alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            alert.view.backgroundColor = [UIColor clearColor];
            alert.delegate = self;
            [alert setInboxMailModel:self.inboxMailModel];
            [alert setIsNotifyMe:self.isNotifyMe];
            
            [self.view addSubview:self.blurEffectView];
            [self presentViewController:alert animated:YES completion:NULL];
        }
            
            break;
            
        default:
            break;
    }
    _snoozeDate = snoozeDate;

    if(indexPath.row != 8 && indexPath.row != 7) {
        //[self presentViewController:dateConfirmationVC animated:YES completion:nil];
        [[KGModal sharedInstance] showWithContentViewController:dateConfirmationVC andAnimated:YES];
    }
    
}
#pragma mark - Actions

- (IBAction)dismissOnTapAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(didCancelSchdule)])
        {
            [self.delegate didCancelSchdule];
        }
    }];
}



- (void)scheduleMailForDate:(NSDate*)date scheduleDateType:(ScheduleDateType)type autoAsk:(NSInteger)autoAsk
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_inboxMailModel.id) {
            [[PMScheduleManager sharedInstance] scheduleMail:_inboxMailModel scheduleDateType:type scheduleDate:date autoAsk:autoAsk];
        }
        
        if ([self.delegate respondsToSelector:@selector(didScheduleWithDateType:date:autoAsk:)])
        {
            [self.delegate didScheduleWithDateType:type date:date autoAsk:autoAsk];
        }
    }];

}

#pragma mark - Alerts Stuff

-(void)showAlert {
    
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to create new folder with name 'Follow up' ?" message:nil delegate:self cancelButtonTitle:@"No, thanks." otherButtonTitles:@"Yes!", nil];
    [self.alertView show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        [[PMAPIManager shared] createFolderWithName:SCHEDULED_FOLDER_NAME account:[PMAPIManager shared].namespaceId comlpetion:^(id data, id error, BOOL success) {
            
            if (!error) {
                
                NSDictionary *dict = (NSDictionary*)data;
                DLog(@"dict = %@", dict);
                
                
            } else {
                [AlertManager showErrorMessage:[NSString stringWithFormat:@"Can't create \"%@\"", SCHEDULED_FOLDER_NAME]];
                
                DLog(@"error = %@", error);
                
            }
            
        }];
    }
    
}

#pragma mark - PMPickerViewControllerDelegate

-(void)PMPickerViewController:(PMPickerViewController *)viewController setDate:(NSDate *)date autoAsk:(NSInteger)autoAsk
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.blurEffectView removeFromSuperview];
    });
    
    [self scheduleMailForDate:date scheduleDateType:PickADate autoAsk:autoAsk];
    
}
-(void)PMPickerViewControllerDismiss:(PMPickerViewController*)viewController {
    [self.blurEffectView removeFromSuperview];
}

#pragma mark - PMSnoozeDateConfirmationControllerDelegate

-(void)PMSnoozeDateConfirmationViewControllerConfirmationAction:(PMSnoozeDateConfirmationViewController *)viewController autoAsk:(NSInteger)autoAsk
{
    [[KGModal sharedInstance] hideAnimated:YES];
    self.autoAsk = autoAsk;
    [self scheduleMailForDate:viewController.date scheduleDateType:_selectedSnoozeType autoAsk:autoAsk];
}

- (void)PMSnoozeDateConfirmationViewControllerDismiss:(PMSnoozeDateConfirmationViewController *)viewController
{
    [[KGModal sharedInstance] hideAnimated:YES];
}

@end
