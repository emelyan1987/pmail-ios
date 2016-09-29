//
//  PMContactInfoTableView.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactInfoTableView.h"
#import "PMMailComposeVC.h"
#import "Config.h"
#import "PMPhoneViewCell.h"
#import "PMEmailViewCell.h"

@interface PMContactInfoTableView() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
@implementation PMContactInfoTableView


- (void)awakeFromNib
{
    [super awakeFromNib];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width/2;
    _profileImageView.clipsToBounds = YES;
    
}

- (void)setContactData:(NSDictionary *)data
{
    _contactData = data;
    
    _nameLabel.text = data[@"name"];
    
    
    NSMutableString *jobTitle = [NSMutableString new];
    
    if(data[@"job"]) [jobTitle appendString:data[@"job"]];
    if(data[@"company"])
    {
        if(jobTitle.length) [jobTitle appendString:@", "];
        [jobTitle appendString:data[@"company"]];
    }
    
    
    _jobLabel.text = jobTitle;
    
    if(data[@"address"])
    {
        _addressLabel.text = data[@"address"];
        _addressLabel.hidden = NO;
    }
    else
    {
        _addressLabel.hidden = YES;
    }
    
    if(data[@"profile_data"])
    {
        UIImage *profileImage = [UIImage imageWithData:data[@"profile_data"]];
        _profileImageView.image = profileImage;
    }
    [_tableView reloadData];
}

#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        NSArray *emails = _contactData[@"emails"];
        return emails.count;
    }
    else
    {
        NSArray *phoneNumbers = _contactData[@"phone_numbers"];
        return phoneNumbers.count;
    }
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(indexPath.section == 0)
    {
        NSString *email = _contactData[@"emails"][indexPath.row];
        PMEmailViewCell *cell = [PMEmailViewCell newCell];
        
        
        [cell bindData:@{@"email":email}];
        
        cell.btnEmailTapAction = ^(id sender) {
            if([self.delegate respondsToSelector:@selector(composeMail:)])
                [self.delegate composeMail:@{@"name":_contactData[@"name"], @"email":email}];
        };
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        NSDictionary *phoneNumber = _contactData[@"phone_numbers"][indexPath.row];
        
        PMPhoneViewCell *cell = [PMPhoneViewCell newCell];
        [cell bindData:phoneNumber];
        
        cell.btnCallTapAction = ^(id sender) {
            if([self.delegate respondsToSelector:@selector(callPhone:)])
                [self.delegate callPhone:phoneNumber[kPhoneNumber]];
        };
        
        cell.btnSMSTapAction = ^(id sender) {
            if([self.delegate respondsToSelector:@selector(sendSMS:)])
                [self.delegate sendSMS:phoneNumber[kPhoneNumber]];
        };
        
        return cell;
    }
    
    return nil;
}

- (IBAction)btnEditTap:(id)sender {
    if(self.btnEditTapAction)
        self.btnEditTapAction(sender);
}
@end
