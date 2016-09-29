//
//  PMSnoozeDateConfirmationViewController.m
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSnoozeDateConfirmationViewController.h"
#import "PMDateConverter.h"
#import "NSDate+DateTools.h"

@interface PMSnoozeDateConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *autoAskButton;
@property (weak, nonatomic) IBOutlet UILabel *notifyTimeCommentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoAskBtnHeightConstraint;

@end

@implementation PMSnoozeDateConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.confirmButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.confirmButton.layer.masksToBounds = YES;
    self.cancelButton.layer.masksToBounds = YES;
    self.dateLabel.layer.cornerRadius = 5.0f;
    self.dateLabel.layer.masksToBounds = YES;
    
    self.bgView.layer.cornerRadius = 7.0f;
    self.bgView.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.autoAskButton.enabled = self.isNotifyMe;
    if(self.isNotifyMe)
    {
        self.titleLabel.text = @"Reminder Confirmation";
        self.notifyTimeCommentLabel.text = @"If no one responds, Return this message to";
        self.autoAskButton.hidden = NO;
    }
    else
    {
        self.titleLabel.text = @"Snooze Confirmation";
        self.notifyTimeCommentLabel.text = @"Return this message to your inbox at";
        self.autoAskButton.hidden = YES;
    }
    
    self.fromLabel.text = self.from;
    self.subjectLabel.text = self.subject && self.subject.length? self.subject : @" ";
    
    self.dateLabel.text = [self.date formattedDateWithFormat:@"  EEEE MMM d, YYYY h:mm a  "];
    
    [self.view setNeedsLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring UI Elements

#pragma mark - Actions

- (IBAction)confirmAction:(id)sender {
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    NSInteger autoAsk;

//    if (self.showAutoAsk) {
    
        if (self.autoAskButton.selected) {
            autoAsk = 1;

        }else{
            autoAsk = 0;

        }
        
//    }else {
//        
//        autoAsk = 2;
//    }
    
    if ([_delegate respondsToSelector:@selector(PMSnoozeDateConfirmationViewControllerConfirmationAction:autoAsk:)]) {
        [_delegate PMSnoozeDateConfirmationViewControllerConfirmationAction:self autoAsk:autoAsk];
    }
    
}

- (IBAction)cancelAction:(id)sender {
 
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    if ([_delegate respondsToSelector:@selector(PMSnoozeDateConfirmationViewControllerDismiss:)]) {
        [_delegate PMSnoozeDateConfirmationViewControllerDismiss:self];
    }
    
}

- (IBAction)autoAskAction:(id)sender {
    
    if (!self.autoAskButton.selected) {
        [self.autoAskButton setImage:[UIImage imageNamed:@"checked1.png"] forState:UIControlStateNormal];
        self.autoAskButton.selected = YES;
    }else {
        [self.autoAskButton setImage:[UIImage imageNamed:@"unchecked1.png"] forState:UIControlStateNormal];
        self.autoAskButton.selected = NO;
    }
    
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
