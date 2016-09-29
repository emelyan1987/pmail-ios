//
//  PMSearchMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/30/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSearchMailVC.h"

#import "PMAPIManager.h"
#import "PMMailTVCell.h"
#import "PMPreviewMailVC.h"
#import "AlertManager.h"
#import "Config.h"
#import "PMThread+Extended.h"

#define CELL_IDENTIFIER @"mailCell"

@interface PMSearchMailVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PMPreviewMailVCDelegate> {
    UISearchBar *_searchBar;
    NSMutableArray *_itemsArray;
    __weak IBOutlet UITableView *_tableView;
    IBOutlet NSLayoutConstraint *_tableViewConstraintBottom;
    
    
    NSMutableDictionary *_eventInfos;   // The event information for mail thread(NSDictionary)
    NSMutableDictionary *_salesforces;  // The data for presenting whether mail comes from salesforce email(BOOL)
    
}

- (void)keyboardWillShow:(NSNotification *)notification;

@end

@implementation PMSearchMailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsArray = [NSMutableArray new];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setDelegate:self];
    [_searchBar setPlaceholder:@"Search"];
    //[_searchBar setTintColor:[UIColor whiteColor]];
    //[_searchBar setBarTintColor:[UIColor whiteColor]];
    
    //[_searchBar setImage:[UIImage imageNamed:@"searchIcon"]        forSearchBarIcon:UISearchBarIconSearch                   state:UIControlStateNormal];
    
    UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
    searchTextField.textColor = UIColorFromRGB(0x1b1b1b);
    searchTextField.font = [UIFont fontWithName:@"Helvetica" size:14];

//    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
//        UIColor *color = [UIColor whiteColor];
//        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: color}]];
//    }
    
    self.navigationItem.titleView = _searchBar;
    
    //[_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searhBarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *lUserInfo = notification.userInfo;
    CGRect lKeyboardFrame = [lUserInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _tableViewConstraintBottom.constant = lKeyboardFrame.size.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableViewConstraintBottom.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)startSearchWithEmail:(NSString *)email {
    
    [AlertManager showProgressBarWithTitle:nil view:self.view];
    
    [[PMAPIManager shared] searchMailWithKeyword:email account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
        [AlertManager hideProgressBar];
        _itemsArray = data;
        [_tableView reloadData];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
            [self updateMailAdditionalInfo];
        });
    }];
}

-(void)updateMailAdditionalInfo
{
    if(_eventInfos == nil) _eventInfos = [NSMutableDictionary new];
    if(_salesforces == nil) _salesforces = [NSMutableDictionary new];
    
    __block NSInteger totalCnt = _itemsArray.count;
    __block NSInteger cnt = 0;
    
    NSManagedObjectContext *context = [[DBManager instance] workerContext];
    
    for(PMThread *model in _itemsArray)
    {
        [model getAdditionalInfo:context completion:^(NSDictionary *info) {
            if(info[@"start_time"])
            {
                [_eventInfos setObject:info forKey:model.id];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_ADDITIONAL_INFO_UPDATED object:model];
            }
            if(info[@"salesforce"])
            {
                [_salesforces setObject:@(YES) forKey:model.id];
            }
            cnt++;
            
            if(cnt == totalCnt)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
        }];
    }
    
    
}

#pragma mark - SearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self startSearchWithEmail:searchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:NO];
    return YES;
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMMailTVCell* cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[PMMailTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    }
    PMThread *lItem = [_itemsArray objectAtIndex:indexPath.row];
    
    BOOL isComeFromSalesforce = NO;
    if(_salesforces[lItem.id]) isComeFromSalesforce = [_salesforces[lItem.id] boolValue];
    [(PMMailTVCell *)cell updateWithModel:lItem keyphrases:nil eventInfo:_eventInfos[lItem.id] salesforce:isComeFromSalesforce];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_itemsArray.count == indexPath.row) {
        return 40;
    }
    
    PMThread *model = _itemsArray[indexPath.row];
    if(_eventInfos[model.id])
        return 115;
    return 90;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPreviewMailVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMPreviewMailVC"];
    vc.delegate = self;
    PMThread *lSelectedModel = _itemsArray[indexPath.row];
    vc.inboxMailModel = lSelectedModel;
    
    vc.inboxMailArray = _itemsArray;
    vc.selectedMailIndex = [_itemsArray indexOfObject:lSelectedModel];
    
    
    [AlertManager showProgressBarWithTitle:nil view:self.view];
    
    [[PMAPIManager shared] getMessagesWithThreadId:lSelectedModel.id forAccount:lSelectedModel.accountId completion:^(id data, id error, BOOL success) {
        
        
        [AlertManager hideProgressBar];
        vc.messages = data;
        vc.isRoot = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}


#pragma mark - PMPreviewMailVC delegate

- (void)PMPreviewMailVCDelegateAction:(PMPreviewMailVCTypeAction)typeAction mail:(PMThread *)model {
    [_tableView reloadData];
}

@end
