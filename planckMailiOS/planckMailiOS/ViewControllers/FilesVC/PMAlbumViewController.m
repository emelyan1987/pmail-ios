//
//  AlbumTableViewController.m
//  Waffer
//
//  Created by Henry on 7/2/15.
//  Copyright (c) 2015 matko. All rights reserved.
//

#import "PMAlbumViewController.h"
#import "PMMediaViewController.h"
#import "PMPhotoManager.h"
#import "UITableView+BackgroundText.h"

@interface PMAlbumViewController(){
    NSMutableArray *albumList;
}
@end

@implementation PMAlbumViewController

-(void)viewDidLoad
{
    NSString *title = @"Gallery";
    
    self.navigationItem.title = title;
    
    [self loadAlbumList];
    
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tableView showEmptyMessage:@"You have no any albums"];
    [self.tableView.backgroundView setHidden:YES];
}

-(void)loadAlbumList
{
    albumList = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [PMPhotoManager defaultAssetsLibrary];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        NSString* name = [group valueForProperty:ALAssetsGroupPropertyName];
        NSInteger count = [group numberOfAssets];
        if(name != nil && count > 0)
        {
            [albumList addObject:group];
        }
        
        [self.tableView.backgroundView setHidden:albumList.count>0];
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"No groups");
    }];
    
    
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [albumList count];
    return count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"albumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the cell...
    int index=(int)indexPath.row;
    ALAssetsGroup *album = [albumList objectAtIndex:index];
    
    NSString *albumName = [album valueForProperty:ALAssetsGroupPropertyName];
    int assetsCount = (int)[album numberOfAssets];
    UIImage *thumbnail = [UIImage imageWithCGImage:[album posterImage]];
    

    [cell.imageView setImage:thumbnail];
    
    [cell.textLabel setText:[albumName stringByAppendingString:[NSString stringWithFormat:@" ( %d ) ", assetsCount]]];
    //cell.textLabel.font=[UIFont fontWithName:@"Helvetica Neue Bold" size:[UIFont systemFontSize]];
    
    return cell;
}
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMMediaViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMediaViewController"];
    
    ALAssetsGroup *album = [albumList objectAtIndex:indexPath.row];
    
    controller.album = album;
    controller.isSelecting = self.isSelecting;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
