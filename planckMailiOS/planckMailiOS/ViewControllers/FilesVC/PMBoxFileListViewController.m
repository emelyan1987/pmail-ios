//
//  PMBoxFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMBoxFileListViewController.h"

#import "PMBoxFileViewController.h"

@interface PMBoxFileListViewController ()

@property (nonatomic, readwrite, strong) NSArray *items;
@property (nonatomic, readwrite, strong) BOXFolder *folder;
@property (nonatomic, readwrite, strong) BOXRequest *request;
@property (nonatomic, readwrite, strong) BOXFileThumbnailRequest *thumbnailRequest;

@property NSMutableArray *filteredItems;
@end

@implementation PMBoxFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!_folderID)
        _folderID = BOXAPIFolderIDRoot;
    
    // Get the current folder's informations
    BOXFolderRequest *folderRequest = [self.client folderInfoRequestWithID:self.folderID];
    [folderRequest performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
        self.folder = folder;
    }];
    
    [self loadItems];
    
    
    
    
    NSString *title = !self.folderName?@"Your Box":self.folderName;
    [self setNavigationBar:title];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_BOX_ACCOUNT_DELETED object:nil];
}

- (void)handlerForAccountDeleted:(NSNotification*)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadItems
{
    [self showLoadingProgressBar];
    
    
    // Retrieve all items from the folder.
    BOXFolderItemsRequest *itemsRequest = [self.client folderItemsRequestWithID:self.folderID];
    itemsRequest.requestAllItemFields = YES;
    [itemsRequest performRequestWithCompletion:^(NSArray *items, NSError *error) {
        if (error == nil) {
            self.items = items;
            
            
            [self.tblFileList reloadData];
        }
        [self hideLoadingProgressBar];
    }];
    
    self.request = itemsRequest;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFilter) return self.filteredItems.count+1;
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
            cell = [PMFileViewCell newCell];
        }
        
        BOXItem *item;
        if(self.isFilter)
            item = self.filteredItems[indexPath.row-1];
        else
            item = self.items[indexPath.row-1];
        
        
        
        cell.lblFileName.text = item.name;
        
        cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.modifiedDate timeIntervalSince1970]]];
        
        
        UIImage *icon;
        if([item isKindOfClass:[BOXFolder class]])
        {
            cell.lblFileSize.hidden = YES;
            CGRect iconSize = cell.imgThumbnail.frame;
            CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
            cell.frame = newSize;
            
            icon = [UIImage imageNamed:@"folder.png"];
        }
        else
        {
            cell.lblFileSize.text = [PMFileManager FileSizeAsString:[((BOXFile*)item).size longLongValue]];
            
            NSString *ext = [[item.name pathExtension] lowercaseString];
            icon = [UIImage imageNamed:[PMFileManager IconFileByExt:ext]];
            
            if([PMFileManager IsThumbnailAbaliable:item.name])
            {
                UIImage *thumbnail = [UIImage imageWithContentsOfFile:[[PMFileManager ThumbnailDirectory:@"Box"] stringByAppendingPathComponent:item.name]];
                
                if(thumbnail)
                {
                    icon = thumbnail;
                }
                else
                {
                    self.thumbnailRequest = [self.client fileThumbnailRequestWithID:item.modelID size:BOXThumbnailSize64];
                    __weak PMFileViewCell *weakCell = cell;
                    
                    [self.thumbnailRequest performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                        if (error == nil) {
                            NSData *imageData = UIImagePNGRepresentation(image);
                            [imageData writeToFile:[[PMFileManager ThumbnailDirectory:@"Box"] stringByAppendingPathComponent:item.name] atomically:YES];
                            
                            // fade animation transition effect
                            weakCell.imgThumbnail.image = image;
                            CATransition *transition = [CATransition animation];
                            transition.duration = 0.3f;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [weakCell.imgThumbnail.layer addAnimation:transition forKey:nil];
                        }
                        else
                        {
                            NSLog(@"%@", error);
                        }
                    }];
                }
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
    
    BOXItem *item;
    if(self.isFilter)
        item = self.filteredItems[indexPath.row-1];
    else
        item = self.items[indexPath.row-1];
    
    UIViewController *controller = nil;
    
    
    if ([item isKindOfClass:[BOXFolder class]]) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
        ((PMBoxFileListViewController*)controller).client = self.client;
        ((PMBoxFileListViewController*)controller).folderID = item.modelID;
        ((PMBoxFileListViewController*)controller).folderName = item.name;
        ((PMBoxFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileViewController"];
        ((PMBoxFileViewController*)controller).client = self.client;
        ((PMBoxFileViewController*)controller).itemID = item.modelID;
        ((PMBoxFileViewController*)controller).itemType = item.type;
        ((PMBoxFileViewController*)controller).isSelecting = self.isSelecting;
    }
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)didFilterButtonPressed:(id)sender
{
    PMFileFilterCell *cell = (PMFileFilterCell*)sender;
    CGRect btnRect = cell.btnFilter.frame;
    CGRect fromRect = CGRectMake(btnRect.origin.x, 64+btnRect.origin.y, btnRect.size.width, btnRect.size.height);
    
    [cell showFilterMenu:self.view fromRect:fromRect];
}

- (void)selectFilterMenu:(NSString *)type
{
    [super selectFilterMenu:type];
    if(self.isFilter)
    {
        [self filterFilesWithType:type];
    }
    
    [self.tblFileList reloadData];
}

-(void)filterFilesWithType:(NSString*)type
{
    [_filteredItems removeAllObjects];
    
    
    if(!_filteredItems) _filteredItems = [NSMutableArray new];
    
    
    for(int i=0; i<_items.count; i++)
    {
        BOXItem *item = [_items objectAtIndex:i];
        
        
        if([PMFileManager IsEqualToType:type filename:item.name])
        {
            [_filteredItems addObject:item];
        }
    }
}



-(void)processSearch:(NSString *)text
{
    [super processSearch:text];
    
    if(self.isFilter)
    {
        [_filteredItems removeAllObjects];
        
        
        if(!_filteredItems) _filteredItems = [NSMutableArray new];
        
        
        for(int i=0; i<_items.count; i++)
        {
            BOXItem *item = [_items objectAtIndex:i];
            
            
            if([[item.name lowercaseString] containsString:[text lowercaseString]])
            {
                [_filteredItems addObject:item];
            }
        }
    }
    
    [self.tblFileList reloadData];
    
    self.searchText = text;
}

#pragma mark - Private Helpers

- (void)updateDataSourceWithNewFile:(BOXFile *)file atIndex:(NSInteger)index
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if (index == NSNotFound) {
        [newItems addObject:file];
    } else {
        [newItems replaceObjectAtIndex:index withObject:file];
    }
    self.items = newItems;
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
