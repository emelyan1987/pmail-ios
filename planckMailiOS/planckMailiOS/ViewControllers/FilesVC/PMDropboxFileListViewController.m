//
//  PMDropBoxFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMDropboxFileListViewController.h"
#import "PMDropboxFileViewController.h"

@interface PMDropboxFileListViewController ()

@end

@implementation PMDropboxFileListViewController
@synthesize loadData;
@synthesize tblFileList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!loadData) {
        loadData = @"";
    }
    
    if(loadData)
    arrayFiles = [[NSMutableArray alloc] init];
    arrayFolders = [[NSMutableArray alloc] init];
    arrayThumbnails = [[NSMutableArray alloc] init];
    
    
    
    [self performSelector:@selector(loadItems) withObject:nil afterDelay:.1];
    
    
    
    //tblFileList.rowHeight = UITableViewAutomaticDimension;
    //tblFileList.estimatedRowHeight = 80.0;
    
    NSString *title;
    if([loadData isEqualToString:@""])
        title = @"Your Dropbox";
    else
    {
        NSArray *token = [loadData pathComponents];
        title = [token lastObject];
    }
    [self setNavigationBar:title];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_DROPBOX_ACCOUNT_DELETED object:nil];
}

- (void)handlerForAccountDeleted:(NSNotification*)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Dropbox Methods
- (DBRestClient *)restClient
{
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return restClient;
}

-(void)loadItems
{
    [self showLoadingProgressBar];
    
    [self.restClient loadMetadata:loadData];
}


#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    for (int i = 0; i < [metadata.contents count]; i++) {
        DBMetadata *data = [metadata.contents objectAtIndex:i];
        
        
        [arrayFiles addObject:data];
        
        
        if(data.isDirectory)
        {
            [arrayThumbnails addObject:@"folder.png"];
        }
        else
        {
            NSString *filename = data.filename;
            NSString *ext = [[filename pathExtension] lowercaseString];
            [arrayThumbnails addObject:[PMFileManager IconFileByExt:ext]];
            
            if(data.thumbnailExists)
            {
                NSString *localThumbnailPath = [[PMFileManager ThumbnailDirectory:@"Dropbox"] stringByAppendingPathComponent:data.filename];
                [restClient loadThumbnail: data.path ofSize:@"l" intoPath:localThumbnailPath];
            }
        }
        
        
    }
    [tblFileList reloadData];
    [self hideLoadingProgressBar];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [tblFileList reloadData];
    [self hideLoadingProgressBar];
}

#pragma mark - DBRestClientDelegate Methods for Download Data
- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)localPath
{
    
    [tblFileList reloadData];
}


#pragma mark - UITableView Delegate Methods
/*-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*int files = 0, folders = 0;
    
    for(int i=0; i<arrayFiles.count; i++)
    {
        DBMetadata *data = [arrayFiles objectAtIndex:i];
        if(data.isDirectory) folders++;
        else files++;
    }
    if(section == 0)
        return files;
    return folders;*/
    
    if(self.isFilter)
        return filteredFiles.count + 1;
    return arrayFiles.count + 1;
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
        DBMetadata *metadata;
        
        if(self.isFilter)
            metadata = [filteredFiles objectAtIndex:indexPath.row-1];
        else
            metadata = [arrayFiles objectAtIndex:indexPath.row-1];
        
        
        PMFileViewCell *cell = [tblFileList dequeueReusableCellWithIdentifier:@"PMFileViewCellID"];
        if (cell == nil)
        {
            cell = [PMFileViewCell newCell];
        }
        
        cell.lblFileName.text = metadata.filename;
        
        UIImage *icon;
        NSString *thumbnailFile;
        
        if(self.isFilter)
            thumbnailFile = [filteredThumbnails objectAtIndex:indexPath.row-1];
        else
            thumbnailFile = [arrayThumbnails objectAtIndex:indexPath.row-1];
        
        icon = [UIImage imageNamed:thumbnailFile];
        
        cell.imgThumbnail.image = icon;
        if(metadata.thumbnailExists)
        {
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[PMFileManager ThumbnailDirectory:@"Dropbox"] stringByAppendingPathComponent:metadata.filename]];
            if(img!=nil) cell.imgThumbnail.image = img;
        }
        
        
        if(metadata.isDirectory)
        {
            cell.lblFileSize.hidden = YES;
            CGRect iconSize = cell.imgThumbnail.frame;
            CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
            cell.frame = newSize;
        }
        else
        {
            cell.lblFileSize.text = metadata.humanReadableSize;
        }
        
        cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[metadata.lastModifiedDate timeIntervalSince1970]]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) return;
    
    DBMetadata *metadata;
    
    if(self.isFilter)
        metadata = [filteredFiles objectAtIndex:indexPath.row-1];
    else
        metadata = [arrayFiles objectAtIndex:indexPath.row-1];
    
    
    
    UIViewController *controller;
    if(metadata.isDirectory)
    {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
        ((PMDropboxFileListViewController*)controller).loadData = metadata.path;
        ((PMDropboxFileListViewController*)controller).isSelecting = self.isSelecting;
    }
    else
    {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileViewController"];
        
        ((PMDropboxFileViewController*)controller).fileitem = metadata;
        ((PMDropboxFileViewController*)controller).restClient = restClient;
        ((PMDropboxFileViewController*)controller).isSelecting = self.isSelecting;
        
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

// Override method from PMFileListViewController
- (void)selectFilterMenu:(NSString *)type
{
    [super selectFilterMenu:type];
    
    [self filterFilesWithType:type];
    
    [tblFileList reloadData];
}

-(void)filterFilesWithType:(NSString*)type
{
    [filteredFiles removeAllObjects];
    [filteredThumbnails removeAllObjects];
    
    if(!filteredFiles) filteredFiles = [NSMutableArray new];
    if(!filteredThumbnails) filteredThumbnails = [NSMutableArray new];

    for(int i=0; i<arrayFiles.count; i++)
    {
        DBMetadata *mdata = [arrayFiles objectAtIndex:i];
        NSString *thumbanail = [arrayThumbnails objectAtIndex:i];
        
        
        if([PMFileManager IsEqualToType:type filename:mdata.filename])
        {
            [filteredFiles addObject:mdata];
            [filteredThumbnails addObject:thumbanail];
        }
    }
}

-(void)processSearch:(NSString *)text
{
    [super processSearch:text];
    
    if(self.isFilter)
    {
        [filteredFiles removeAllObjects];
        [filteredThumbnails removeAllObjects];
        
        if(!filteredFiles) filteredFiles = [NSMutableArray new];
        if(!filteredThumbnails) filteredThumbnails = [NSMutableArray new];
        
        for(int i=0; i<arrayFiles.count; i++)
        {
            DBMetadata *mdata = [arrayFiles objectAtIndex:i];
            NSString *thumbanail = [arrayThumbnails objectAtIndex:i];
            
            
            if([[mdata.filename lowercaseString] containsString:[text lowercaseString]])
            {
                [filteredFiles addObject:mdata];
                [filteredThumbnails addObject:thumbanail];
            }
        }
    }
    
    [tblFileList reloadData];
    
    self.searchText = text;
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
