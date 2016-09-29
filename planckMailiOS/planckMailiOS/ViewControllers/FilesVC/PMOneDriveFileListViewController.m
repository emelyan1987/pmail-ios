//
//  PMOneDriveFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMOneDriveFileListViewController.h"
#import "PMOneDriveFileViewController.h"
#import "AlertManager.h"


@interface PMOneDriveFileListViewController ()

@property NSMutableDictionary *items;
@property NSMutableArray *itemIds;
@property NSMutableDictionary *thumbnails;

@property NSMutableArray *filteredItemIds;
@end

@implementation PMOneDriveFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if (!self.folder){
        title = @"Your OneDrive";
    }
    else
    {
        title = self.folder.name;
    }
    
    [self setNavigationBar:title];
    
    self.items = [[NSMutableDictionary alloc] init];
    self.itemIds = [[NSMutableArray alloc] init];
    self.thumbnails = [[NSMutableDictionary alloc] init];
    
    [self performSelector:@selector(loadItems) withObject:nil afterDelay:.1];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_ONEDRIVE_ACCOUNT_DELETED object:nil];
    
    
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
    NSString *itemId = (self.folder) ? self.folder.id : @"root";
    
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemId] children] request];
    if (![self.client serviceFlags][@"NoThumbnails"]){
        [childrenRequest expand:@"thumbnails"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingProgressBar];
    });

    [self loadChildrenWithRequest:childrenRequest];
}

- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self hideLoadingProgressBar];
        });
        
        if (!error)
        {
            if (response.value)
            {
                [self onLoadedChildren:response.value];
            }
            if (nextRequest)
            {
                [self loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError])
        {
            [self showErrorAlert:error];
            [self onLoadedChildren:@[]];
        }
        
    }];
}

- (void)onLoadedChildren:(NSArray *)children
{
    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
        if (![self.itemIds containsObject:item.id]){
            [self.itemIds addObject:item.id];
        }
        self.items[item.id] = item;
    }];
    [self loadThumbnails:children];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tblFileList reloadData];
    });
}

- (void)loadThumbnails:(NSArray *)items{
    for (ODItem *item in items){
        @try {
            NSString *name = item.name; DLog(@"Item Name:%@", name);
            NSString *filepath = [[PMFileManager ThumbnailDirectory:@"OneDrive"] stringByAppendingPathComponent:name];
            
            filepath = [filepath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
            UIImage *thumbnail = [UIImage imageWithContentsOfFile:filepath];
            
            if(thumbnail)
            {
                self.thumbnails[item.id] = thumbnail;
            }
            else if ([item thumbnails:0])
            {
                [[[[[[self.client drive] items:item.id] thumbnails:@"0"] small] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    if (!error){
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                        NSData *imageData = UIImagePNGRepresentation(image);
                        [imageData writeToFile:[[PMFileManager ThumbnailDirectory:@"OneDrive"] stringByAppendingPathComponent:item.name] atomically:YES];
                        
                        self.thumbnails[item.id] = image;
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.tblFileList reloadData];
                        });
                    }
                }];
            }
        } @catch (NSException *exception) {
            DLog(@"Exception error: %@", exception);
        } @finally {
            
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFilter) return _filteredItemIds.count+1;
    return self.itemIds.count+1;
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
        
        ODItem *item;
        
        if(self.isFilter)
            item = self.items[self.filteredItemIds[indexPath.row-1]];
        else
            item = self.items[self.itemIds[indexPath.row-1]];
        
        cell.lblFileName.text = item.name;
        
        cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.lastModifiedDateTime timeIntervalSince1970]]];
        
        UIImage *icon;
        
        if(item.folder)
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
                
                if (self.thumbnails[item.id]){
                    icon = self.thumbnails[item.id];
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
    
    ODItem *item;
    
    if(self.isFilter)
        item = self.items[self.filteredItemIds[indexPath.row-1]];
    else
        item = self.items[self.itemIds[indexPath.row-1]];
    
    UIViewController *controller = nil;
    
    if (item.folder) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileListViewController"];
        ((PMOneDriveFileListViewController*)controller).client = self.client;
        ((PMOneDriveFileListViewController*)controller).folder = item;
        ((PMOneDriveFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileViewController"];
        ((PMOneDriveFileViewController*)controller).client = self.client;
        ((PMOneDriveFileViewController*)controller).fileitem = item;
        ((PMOneDriveFileViewController*)controller).isSelecting = self.isSelecting;
    }
    [self.navigationController pushViewController:controller animated:YES];
}



- (void)showErrorAlert:(NSError*)error
{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"There was an Error!"
                                                                        message:[NSString stringWithFormat:@"%@", error]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [errorAlert addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errorAlert animated:YES completion:nil];
    });
    
}

#pragma PMFileFilterCellDelegate Methods
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
    if(!_filteredItemIds) _filteredItemIds = [NSMutableArray new];
    
    [_filteredItemIds removeAllObjects];
    
    for(int i=0; i<_items.count; i++)
    {
        NSString *itemId = [_itemIds objectAtIndex:i];
        
        ODItem *item = self.items[self.itemIds[i]];
        
        if([PMFileManager IsEqualToType:type filename:item.name])
        {
            [_filteredItemIds addObject:itemId];
        }
    }
}

-(void)processSearch:(NSString *)text
{
    [super processSearch:text];
    
    if(self.isFilter)
    {
        if(!_filteredItemIds) _filteredItemIds = [NSMutableArray new];
        
        [_filteredItemIds removeAllObjects];
        
        for(int i=0; i<_items.count; i++)
        {
            NSString *itemId = [_itemIds objectAtIndex:i];
            
            ODItem *item = self.items[self.itemIds[i]];
            
            if([[item.name lowercaseString] containsString:[text lowercaseString]])
            {
                [_filteredItemIds addObject:itemId];
            }
        }
    }
    
    [self.tblFileList reloadData];
    
    self.searchText = text;
}
@end
