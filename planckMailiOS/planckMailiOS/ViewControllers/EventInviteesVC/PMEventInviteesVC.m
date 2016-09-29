//
//  PMEventInviteesVC.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventInviteesVC.h"
#import "CLTokenInputView.h"
#import "DBManager.h"
#import "PMAPIManager.h"
#import "DBSavedContact.h"

@interface PMEventInviteesVC () <CLTokenInputViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSArray* contacts;
    NSMutableArray *filteredContacts;
    
    NSMutableArray *selectedPeoples;
    
    CGFloat keyboardHeight;
}
@property (weak, nonatomic) IBOutlet CLTokenInputView *tokenInputView;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *peopleTivHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactTblHeightConstraint;

@end

@implementation PMEventInviteesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //_tokenInputView.fieldName = @"To:";
    _tokenInputView.placeholderText = @"Enter people name or email";
    _tokenInputView.drawBottomBorder = YES;
    _tokenInputView.delegate = self;
    
    
    contacts = [[DBManager instance] getSavedContacts];
    
    
    
    selectedPeoples = [NSMutableArray new];
    
    if(_peoples && _peoples.count>0)
    {
        for(NSDictionary *people in _peoples)
        {
            NSString *email = people[@"email"];
            DBSavedContact *savedContact = [DBSavedContact getContactWithEmail:email];
            
            NSString *displayText = ([people[@"name"] isEqual:[NSNull null]] || ((NSString*)people[@"name"]).length)==0?people[@"email"]:people[@"name"];
            if(savedContact && savedContact.name && savedContact.name.length) displayText = savedContact.name;
            
            NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
            
            NSDictionary *context = @{@"name":displayText, @"email":people[@"email"]};
            CLToken *token = [[CLToken alloc] initWithDisplayText:displayText context:context type:type];
            [_tokenInputView addToken:token];
        }
    }
    
    
    [self setNavigationBar];
    
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"DONE"  style:UIBarButtonItemStylePlain target:self action:@selector(onDone)];
    
    [doneBtn setTitleTextAttributes:@{
                                      NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0f],
                                      NSForegroundColorAttributeName: [UIColor whiteColor]
                                      } forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Select Peoples";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}



-(void)onDone
{
    if([self.delegate respondsToSelector:@selector(didSelectPeoples:)])
        [self.delegate didSelectPeoples:selectedPeoples];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

}


- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    keyboardHeight = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteesFilterContactCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"InviteesFilterContactCell"];
    }
    
    NSDictionary *contact = [filteredContacts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = contact[@"name"];
    cell.detailTextLabel.text = contact[@"email"];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return filteredContacts.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if([tableView isEqual:self.contactTableView])
    {
        NSDictionary *item = [filteredContacts objectAtIndex:indexPath.row];
        
        DBSavedContact *savedContact = item[@"obj"];
        
        NSString *displayText = item[@"name"];
        if(savedContact && savedContact.name && savedContact.name.length) displayText = savedContact.name;
        
        NSInteger type = !savedContact ? 0 : [savedContact getContactTypeValue];
        
        NSDictionary *context = @{@"name":displayText, @"email":item[@"email"]};
        CLToken *token = [[CLToken alloc] initWithDisplayText:displayText context:context type:type];
        if (self.tokenInputView.isEditing) {
            [self.tokenInputView addToken:token];
        }
        
    }
}

#pragma mark - CLTokenInputViewDelegate

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text
{
    if ([text isEqualToString:@""]){
        filteredContacts = nil;
        //self.contactTableView.hidden = YES;
    } else {
        NSString *keyword = [NSString stringWithFormat:@"*%@*", text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) or (emails like[cd] %@)", keyword, keyword];
        
        NSArray *tempContacts = [contacts filteredArrayUsingPredicate:predicate];
        
        filteredContacts = [NSMutableArray new];
        for(DBSavedContact *contact in tempContacts)
        {
            NSArray *emails = [contact getEmailArray];
            
            for(NSString *email in emails)
            {
                [filteredContacts addObject:@{@"name":[contact getTitle], @"email":email, @"obj":contact}];
            }
        }
    }
    [self.contactTableView reloadData];
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    
    if([view isEqual:self.tokenInputView])
        [selectedPeoples addObject:token.context];
    
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    
    //NSString *email = contact.email;
    if([view isEqual:self.tokenInputView])
        [selectedPeoples removeObject:token.context];
    
}

- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    NSDictionary *context = @{@"email":text, @"name":@""/*, @"status":@YES*/};
    
    CLToken *token = [[CLToken alloc] initWithDisplayText:text context:context];
    
    return token;
    
    // TODO: Perhaps if the text is a valid phone number, or email address, create a token
    // to "accept" it.
    //return nil;
}

- (void)tokenInputViewDidEndEditing:(CLTokenInputView *)view
{
    NSLog(@"token input view did end editing: %@", view);
    //view.accessoryView = nil;
}

- (void)tokenInputViewDidBeginEditing:(CLTokenInputView *)view
{
    
    self.contactTblHeightConstraint.constant = self.view.frame.size.height - keyboardHeight - view.frame.origin.y - view.frame.size.height;
    [self.view layoutIfNeeded];
    
    filteredContacts = nil;
    [self.contactTableView reloadData];
}

-(void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height
{
    if([view isEqual:self.tokenInputView])
        self.peopleTivHeightConstraint.constant = height;
    
    [self.view layoutIfNeeded];
}
@end
