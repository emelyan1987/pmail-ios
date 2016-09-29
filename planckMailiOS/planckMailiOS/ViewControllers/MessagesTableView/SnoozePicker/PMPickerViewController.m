//
//  PMPickerViewController.m
//  planckMailiOS
//
//  Created by nazar on 11/2/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import "PMPickerViewController.h"
#import "PMSnoozeDateConfirmationViewController.h"
#import "PMDateConverter.h"
#import "PMSnoozeDateConfirmationViewController.h"
#import "KGModal.h"

@interface PMPickerViewController () <PMSnoozeDateConfirmationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@end

@implementation PMPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dateLabel.text = [PMDateConverter getStringDateFromDate:self.datePicker.date];
   
    [self configureBaseView];
    [self configureBlurEffect];
    [self configureDatePicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring UI Elements

-(void)configureBaseView {

    self.baseView.layer.cornerRadius = 10.f;
    self.baseView.layer.masksToBounds = YES;
    [self.baseView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.baseView.layer setBorderWidth:2];
    self.baseView.backgroundColor = [UIColor clearColor];
}

-(void)configureDatePicker {

    NSDate *date = [NSDate date];
    date = [NSDate date];
    
    self.datePicker.minimumDate = date;
    
    int difference = [PMDateConverter getDifferenceFromDate:self.datePicker.date];
    
    NSDate *maximumDate = [date dateByAddingTimeInterval:60*60*24*difference];

    self.datePicker.maximumDate = maximumDate;
    [self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    self.datePicker.backgroundColor = [UIColor clearColor];
}

-(void)configureBlurEffect {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    self.blurEffectView.frame = [UIScreen mainScreen].bounds;
}

#pragma mark - Actions

- (IBAction)previousMonthAction:(id)sender {
  
    NSDate *date = self.datePicker.date;
    
    date = [date dateByAddingTimeInterval:-(60*60*24*30)];
    
    
    if ([[NSDate date] compare:date] == NSOrderedDescending) {
        [self.datePicker setDate:[NSDate date] animated:YES];
        [self reloadPickerLabel];
        return;
    }
    
    [self.datePicker setDate:date animated:YES];

    [self reloadPickerLabel];

}

- (IBAction)nextMonthAction:(id)sender {
    
    
    NSTimeInterval originalTimeInterval = 60*60*24*[PMDateConverter getDifferenceFromDate:self.datePicker.date];
    
    NSDate *date = self.datePicker.date;
    
    date = [date dateByAddingTimeInterval:60*60*24*30];

    
    NSTimeInterval tmint = [date timeIntervalSinceNow];

    if (tmint > originalTimeInterval) {
        return;
    }
  
    [self.datePicker setDate:date animated:YES];
    [self reloadPickerLabel];

}

- (IBAction)datePickerIsChanged:(id)sender {
   
    [self reloadPickerLabel];
}

- (IBAction)setDateAction:(id)sender {

    PMSnoozeDateConfirmationViewController *dateConfirmationVC = [[PMSnoozeDateConfirmationViewController alloc] init];
   
    dateConfirmationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    dateConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    dateConfirmationVC.view.backgroundColor = [UIColor clearColor];
    [dateConfirmationVC setFrom:self.inboxMailModel.ownerName];
    [dateConfirmationVC setSubject:self.inboxMailModel.subject];
    [dateConfirmationVC setDate:self.datePicker.date];
    [dateConfirmationVC setIsNotifyMe:self.isNotifyMe];
    dateConfirmationVC.delegate = self;
    
    
    //[self.view addSubview:self.blurEffectView];
    
    [[KGModal sharedInstance] showWithContentViewController:dateConfirmationVC andAnimated:YES];
}

- (IBAction)cancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([_delegate respondsToSelector:@selector(PMPickerViewControllerDismiss:)]) {
        [_delegate PMPickerViewControllerDismiss:self];
    }
}

#pragma mark - PMSnoozeDateConfirmationViewController

-(void)PMSnoozeDateConfirmationViewControllerDismiss:(PMSnoozeDateConfirmationViewController *)viewController {

    //[self.blurEffectView removeFromSuperview];
    [[KGModal sharedInstance] hideAnimated:YES];
    
}

-(void)PMSnoozeDateConfirmationViewControllerConfirmationAction:(PMSnoozeDateConfirmationViewController *)viewController autoAsk:(NSInteger)autoAsk {
    [[KGModal sharedInstance] hideAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([_delegate respondsToSelector:@selector(PMPickerViewController:setDate:autoAsk:)]) {
        [_delegate PMPickerViewController:self setDate:self.datePicker.date autoAsk:autoAsk];
    }
}

#pragma mark - Other stuff

-(void)reloadPickerLabel {
    self.dateLabel.text = [PMDateConverter getStringDateFromDate:self.datePicker.date];
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
