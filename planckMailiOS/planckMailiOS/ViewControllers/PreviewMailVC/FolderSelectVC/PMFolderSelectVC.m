//
//  PMFolderSelectVC.m
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMFolderSelectVC.h"
#import "PMFolderManager.h"
#import "PMFolderCell.h"



@interface PMFolderSelectVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnItemBackClicked:(id)sender;

@property (nonatomic, strong) NSMutableArray *folders;
@end

@implementation PMFolderSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadFolderData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnItemBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadFolderData
{
    _folders = [NSMutableArray arrayWithArray:[[PMFolderManager sharedInstance] getFoldersForAccount:_accountId]];
    
    [_tableView reloadData];
}

#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _folders.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"folderCell"];
    if(cell==nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"folderCell"];
    //PMFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"folderCell"];

    NSDictionary *folder = _folders[indexPath.row];
    
    //[cell bindData:folder selected:NO];
    NSString *displayName = folder[@"display_name"];
    NSString *name = folder[@"name"];
    
    cell.textLabel.text = displayName;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_menu_icon", [name lowercaseString]]];
    
    if(!img)
        img = [UIImage imageNamed:@"folder_menu_icon"];
    cell.imageView.image = img;
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *folder = _folders[indexPath.row];
    
    if([_delegate respondsToSelector:@selector(didSelectFolder:)])
    {
        [_delegate didSelectFolder:folder[@"id"]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
