//
//  PMGoogleDriveFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMGoogleDriveFileListViewController.h"
#import "PMGoogleDriveFileViewController.h"

@interface PMGoogleDriveFileListViewController ()



@property NSMutableArray *items;
@property NSMutableArray *filteredItems;
@end

@implementation PMGoogleDriveFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if(!_folder)
    {
        title = @"Your GoogleDrive";
    }
    else
    {
        title = _folder.title;
    }
    
    [self setNavigationBar:title];
    
    self.service.shouldFetchNextPages = YES;
    
    [self performSelector:@selector(loadItems:) withObject:nil afterDelay:.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_GOOGLEDRIVE_ACCOUNT_DELETED object:nil];
}
- (void)handlerForAccountDeleted:(NSNotification*)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadItems:(NSString *)pageToken
{
    [self showLoadingProgressBar];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    
    NSString *parentId;
    if(!_folder) parentId = @"root";
    else parentId = _folder.identifier;
    
    query.q = [NSString stringWithFormat:@"'%@' in parents and trashed = false", parentId];
    
    if(pageToken) query.pageToken = pageToken;
    
    [_service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFileList *files,
                                                  NSError *error) {
        
        if (error == nil) {
            NSLog(@"Have results");
            // Iterate over files.items array
            
            if(_items==nil) _items = [[NSMutableArray alloc] init];
            
            [_items addObjectsFromArray:files.items];
            [self.tblFileList reloadData];
            
            
            if (files.nextPageToken) {
                [self loadItems:files.nextPageToken];
            }
            
        } else {
            NSLog(@"An error occurred: %@", error);
        }
        
        [self hideLoadingProgressBar];
    }];
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
        
        GTLDriveFile *item;
        if(self.isFilter)
            item = self.filteredItems[indexPath.row-1];
        else
            item = self.items[indexPath.row-1];
        
        cell.lblFileName.text = item.title;
        
        cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.modifiedDate.date timeIntervalSince1970]]];
        
        UIImage *icon;
        
        NSString *mimeType = item.mimeType;
        if([mimeType isEqualToString:@"application/vnd.google-apps.folder"])
        {
            cell.lblFileSize.hidden = YES;
            CGRect iconSize = cell.imgThumbnail.frame;
            CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
            cell.frame = newSize;
            
            icon = [UIImage imageNamed:@"folder.png"];
        }
        else
        {
            cell.lblFileSize.text = [PMFileManager FileSizeAsString:[item.fileSize longLongValue]];
            
            icon = [UIImage imageNamed:[PMFileManager IconFileByExt:item.fileExtension]];
            
            
            NSString *thumbnailLink = item.thumbnailLink;
            if(thumbnailLink)
            {
                UIImage *thumbnail = [UIImage imageWithContentsOfFile:[[PMFileManager ThumbnailDirectory:@"GoogleDrive"] stringByAppendingPathComponent:item.title]];
                
                if(thumbnail)
                {
                    icon = thumbnail;
                }
                else
                {
                    NSURL *thumbnailURL = [NSURL URLWithString:thumbnailLink];
                    
                    __weak PMFileViewCell *weakCell = cell;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
                        
                        UIImage *imageFromData = [UIImage imageWithData:imageData];
                        
                        
                        
                        if (imageFromData) {
                            [imageData writeToFile:[[PMFileManager ThumbnailDirectory:@"GoogleDrive"] stringByAppendingPathComponent:item.title] atomically:YES];
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                
                                weakCell.imgThumbnail.image = imageFromData;
                                
                                CATransition *transition = [CATransition animation];
                                transition.duration = 0.3f;
                                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                transition.type = kCATransitionFade;
                                [weakCell.imgThumbnail.layer addAnimation:transition forKey:nil];
                            });
                        }
                        
                    });
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
    
    GTLDriveFile *item;
    if(self.isFilter)
        item = self.filteredItems[indexPath.row-1];
    else
        item = self.items[indexPath.row-1];
    
    UIViewController *controller = nil;
    
    if ([item.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileListViewController"];
        ((PMGoogleDriveFileListViewController*)controller).service = self.service;
        ((PMGoogleDriveFileListViewController*)controller).folder = item;
        ((PMGoogleDriveFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileViewController"];
        ((PMGoogleDriveFileViewController*)controller).service = self.service;
        ((PMGoogleDriveFileViewController*)controller).fileitem = item;
        ((PMGoogleDriveFileViewController*)controller).isSelecting = self.isSelecting;
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
    if(!_filteredItems) _filteredItems = [NSMutableArray new];
    
    [_filteredItems removeAllObjects];
    
    for(int i=0; i<_items.count; i++)
    {
        GTLDriveFile *item = [_items objectAtIndex:i];
        
        
        if([PMFileManager IsEqualToType:type filename:item.title])
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
        if(!_filteredItems) _filteredItems = [NSMutableArray new];
        
        [_filteredItems removeAllObjects];
        
        for(int i=0; i<_items.count; i++)
        {
            GTLDriveFile *item = [_items objectAtIndex:i];
            
            
            if([[item.title lowercaseString] containsString:[text lowercaseString]])
            {
                [_filteredItems addObject:item];
            }
        }
    }
    
    [self.tblFileList reloadData];
    
    self.searchText = text;
}

@end
