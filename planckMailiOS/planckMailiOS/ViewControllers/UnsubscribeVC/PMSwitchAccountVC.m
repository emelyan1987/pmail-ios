//
//  PMSwitchAccountVC.m
//  planckMailiOS
//
//  Created by LionStar on 4/12/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSwitchAccountVC.h"
#import "DBManager.h"
#import "PMAccountTVC.h"
#import "PMAPIManager.h"


#define CELL_IDENTIFIER @"accountCell"

@interface PMSwitchAccountVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;


- (IBAction)btnOkClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) DBNamespace *candidateAccount;
@end

@implementation PMSwitchAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnOk.layer.cornerRadius = 5.0f;
    self.btnCancel.layer.cornerRadius = 5.0f;
    self.btnOk.layer.masksToBounds = YES;
    self.btnCancel.layer.masksToBounds = YES;
    
    self.bgView.layer.cornerRadius = 7.0f;
    self.bgView.clipsToBounds = YES;
    
    _accounts = [[DBManager instance] getNamespaces];
    
    _candidateAccount = _selectedAccount;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _accounts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMAccountTVC *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    DBNamespace *account = _accounts[indexPath.row];
    
    NSString *email = account.email_address;
    [cell setEmail:account.email_address selected:[email isEqualToString:_candidateAccount.email_address]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _candidateAccount = _accounts[indexPath.row];
    
    [_tableView reloadData];
}
- (IBAction)btnOkClicked:(id)sender {
    if([_delegate respondsToSelector:@selector(dismissSwitchAccountVCWithSelectedAccount:)])
        [_delegate dismissSwitchAccountVCWithSelectedAccount:_candidateAccount];
}

- (IBAction)btnCancelClicked:(id)sender {
    if([_delegate respondsToSelector:@selector(dismissSwitchAccountVCWithSelectedAccount:)])
        [_delegate dismissSwitchAccountVCWithSelectedAccount:_selectedAccount];
}
@end
