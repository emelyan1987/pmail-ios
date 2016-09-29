//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSetSignatureTVC.h"
#import "DBManager.h"
#import "PMSettingsManager.h"
#import "PMSettingsSwitchTVCell.h"
#import "PMSettingsTextViewTVCell.h"




@interface PMSetSignatureTVC () <UITableViewDataSource, UITableViewDelegate, PMSettingsSwitchTVCellDelegate, PMSettingsTextViewTVCellDelegate>
{
    NSMutableArray *_sections;
    
    NSArray *_namespaces;
    
    BOOL _perAccountSignature;
}
@end

@implementation PMSetSignatureTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self buildSectionData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Signature";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)buildSectionData
{
    _sections = [NSMutableArray new];
    
    [_sections addObject:@""];
    
    
    BOOL perAccountSignature = [[PMSettingsManager instance] getPerAccountSignature];
    
    if(!perAccountSignature)
        [_sections addObject:@"SIGNATURE"];
    else
    {
        NSArray *namespaces = [[DBManager instance] getNamespaces];
        
        for(DBNamespace *namespace in namespaces)
        {
            [_sections addObject:namespace.email_address];
        }
    }
    
    
}


#pragma UITableViewDataSource & UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) return 44;
    else return 110;
        
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = _sections[section];
    
    return sectionTitle;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==0)
    {
        PMSettingsSwitchTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"perAccountSignatureCell"];
        cell.delegate = self;
        cell.switchControl.on = [[PMSettingsManager instance] getPerAccountSignature];
        return cell;
    }
    else
    {
        NSString *sectionTitle = _sections[indexPath.section];
        
        PMSettingsTextViewTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signatureCell"];
        cell.delegate = self;
        cell.tagString = sectionTitle;
        
        if([sectionTitle isEqualToString:@"SIGNATURE"])
        {
            cell.textView.text = [[PMSettingsManager instance] getGeneralSignature];
        }
        else
        {
            NSDictionary *signatures = [[PMSettingsManager instance] getSignaturesForAccount];
            
            NSString *signature = signatures[sectionTitle];
            if(signature==nil) signature = [[PMSettingsManager instance] getGeneralSignature];
            cell.textView.text = signature;
        }
        
        return cell;
    }
}



#pragma mark PMSettingsSwitchTVCellDelegate

-(void)switchCell:(PMSettingsSwitchTVCell *)cell switchControllValueChanged:(BOOL)value
{
    [[PMSettingsManager instance] setPerAccountSignature:value];
    
    [self buildSectionData];
    [self.tableView reloadData];
    
    _perAccountSignature = value;
    
    if([self.delegate respondsToSelector:@selector(signatureTVC:didSetSignature:signatureData:)])
        [self.delegate signatureTVC:self didSetSignature:_perAccountSignature signatureData:nil];
}
#pragma mark PMSettingsTextViewTVCellDelegate

-(void)textViewCell:(PMSettingsTextViewTVCell *)cell textDidChange:(NSString *)text
{
    NSString *tagString = cell.tagString;
    
    if([tagString isEqualToString:@"SIGNATURE"])
        [[PMSettingsManager instance] setGeneralSignature:text];
    else
    {
        NSDictionary *signatures = [[PMSettingsManager instance] getSignaturesForAccount];
        
        NSMutableDictionary *mutableSignatures;
        if(signatures)
            mutableSignatures = [NSMutableDictionary dictionaryWithDictionary:signatures];
        else
            mutableSignatures = [NSMutableDictionary new];
        
        [mutableSignatures setObject:text forKey:tagString];
        
        [[PMSettingsManager instance] setSignaturesForAccount:mutableSignatures];
    }
    
    //[self.tableView reloadData];
    
    if([self.delegate respondsToSelector:@selector(signatureTVC:didSetSignature:signatureData:)])
        [self.delegate signatureTVC:self didSetSignature:_perAccountSignature signatureData:nil];
        
}
@end
