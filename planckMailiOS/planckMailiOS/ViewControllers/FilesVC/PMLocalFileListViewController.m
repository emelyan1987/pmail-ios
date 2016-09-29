//
//  PMLocalFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMLocalFileListViewController.h"
#import "PMLocalFileViewController.h"
#import "PMFileManager.h"
#import "PMFileItem.h"
#import "UITableView+BackgroundText.h"


@interface PMLocalFileListViewController ()

@property NSMutableArray *items;
@property NSMutableArray *filteredItems;
@end

@implementation PMLocalFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if(!_path)
    {
        title = @"Your Mobile";
        _path = @"";
    }
    else
        title = [_path lastPathComponent];
    
    [self setNavigationBar:title];
    
    [self.tblFileList showEmptyMessage:@"You have no files"];
    [self.tblFileList.backgroundView setHidden:YES];
    
    _absolutePath = [[PMFileManager MobileDirectory] stringByAppendingPathComponent:_path];
    
    [self loadItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadItems
{
    if(_items==nil) _items = [[NSMutableArray alloc] init];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_absolutePath error:nil];
    for(NSString *name in contents)
    {
        PMFileItem *item = [[PMFileItem alloc] init];
        
        item.name = name;
        item.path = [_path stringByAppendingPathComponent:name];
        item.fullpath = [_absolutePath stringByAppendingPathComponent:name];
        NSError *error;
        NSDictionary<NSString *,id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_absolutePath stringByAppendingPathComponent:name] error:&error];
        
        if(error==nil)
        {
            item.size = [attributes fileSize];
            item.modifiedTime = [attributes fileModificationDate];
            item.isDirectory = [[attributes fileType] isEqualToString:NSFileTypeDirectory];
            item.type = [attributes fileType];
        }
        
        [_items addObject:item];
        
    }
    
    [self.tblFileList.backgroundView setHidden:_items.count>0];
    [self.tblFileList reloadData];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFilter)
        return self.filteredItems.count+1;
    return self.items.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        PMFileFilterCell *filterCell = (PMFileFilterCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMFileFilterCell class])];;
        if(!filterCell) {
            filterCell = [PMFileFilterCell newCell];
        }
        
        filterCell.lblFilterName.text = self.filterName;
        filterCell.delegate = self;
        
        return filterCell;
    }
    else
    {
        PMFileViewCell *cell = [self.tblFileList dequeueReusableCellWithIdentifier:@"PMFileViewCellID"];
        if (cell == nil)
        {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PMFileViewCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        PMFileItem *item;
        
        if(self.isFilter)
            item = self.filteredItems[indexPath.row-1];
        else
            item = self.items[indexPath.row-1];
        
        cell.lblFileName.text = item.name;
        
        cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.modifiedTime timeIntervalSince1970]]];
        
        UIImage *icon;
        
        if(item.isDirectory)
        {
            cell.lblFileSize.hidden = YES;
            CGRect iconSize = cell.imgThumbnail.frame;
            CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
            cell.frame = newSize;
            
            icon = [UIImage imageNamed:@"folder.png"];
        }
        else
        {
            cell.lblFileSize.text = [PMFileManager FileSizeAsString:item.size];
            
            
            icon = [UIImage imageNamed:[PMFileManager IconFileByExt:[[item.name pathExtension] lowercaseString]]];
            
            
            if([PMFileManager IsThumbnailAbaliable:item.name])
            {
                
                UIImage *thumbnail = [PMFileManager ThumbnailFromFile:[[PMFileManager MobileDirectory] stringByAppendingPathComponent:item.path]];
                if(thumbnail)
                    icon = thumbnail;
                
            }
            
            
        }
        
        
        cell.imgThumbnail.image = icon;
        
        
        
        
        return cell;

    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) return;
    
    PMFileItem *item;
    
    if(self.isFilter)
        item = self.filteredItems[indexPath.row-1];
    else
        item = self.items[indexPath.row-1];
    
    
    UIViewController *controller = nil;
    
    if (item.isDirectory) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileListViewController"];
        ((PMLocalFileListViewController*)controller).path = item.path;
        
        ((PMLocalFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileViewController"];
        ((PMLocalFileViewController*)controller).fileitem = item;
        
        ((PMLocalFileViewController*)controller).isSelecting = self.isSelecting;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma PMFileFilterCellDelegate Methods
-(void)didFilterButtonPressed:(id)sender
{
    PMFileFilterCell *cell = (PMFileFilterCell*)sender;
    CGRect btnRect = cell.btnFilter.frame;
    CGRect fromRect = CGRectMake(btnRect.origin.x, 64+btnRect.origin.y, btnRect.size.width, btnRect.size.height);
    
    [cell showFilterMenu:self.view fromRect:fromRect];
}

- (void)selectFilterMenu:(NSString *)menuTitle
{
    [super selectFilterMenu:menuTitle];
    if(self.isFilter)
    {
        [self filterFilesWithType:menuTitle];
    }
    
    [self.tblFileList reloadData];
}

-(void)filterFilesWithType:(NSString*)type
{
    if(!_filteredItems) _filteredItems = [NSMutableArray new];
    
    [_filteredItems removeAllObjects];
    
    for(int i=0; i<_items.count; i++)
    {
        PMFileItem *item = [self.items objectAtIndex:i];
        
        if([PMFileManager IsEqualToType:type filename:item.name])
        {
            [_filteredItems addObject:item];
        }
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
