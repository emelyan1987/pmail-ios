//
//  MediaViewController.m
//  Waffer
//
//  Created by Henry on 7/3/15.
//  Copyright (c) 2015 matko. All rights reserved.
//

#import "PMMediaViewController.h"
#import "PMMediaCell.h"
#import "PMPhotoManager.h"
#import "AlertManager.h"
#import "PMFileManager.h"
#import "PMLocalFileViewController.h"
#import "UICollectionView+BackgroundText.h"

@interface PMMediaViewController()

@property(nonatomic, strong) NSMutableArray *mediaList;
@property(nonatomic, strong) NSString *albumName;
@end
@implementation PMMediaViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _albumName = [_album valueForProperty:ALAssetsGroupPropertyName];
    self.navigationItem.title = _albumName;
    
    [self.collectionView showEmptyMessage:@"You have no any media"];
    [self.collectionView.backgroundView setHidden:YES];
    
    [self loadMediaList];
}

-(void)loadMediaList
{
    if(_mediaList==nil) _mediaList = [NSMutableArray new];
    
    
    ALAssetsLibrary *library = [PMPhotoManager defaultAssetsLibrary];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        
        if([groupName isEqualToString:_albumName])
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if(asset != nil)
                {
                    [_mediaList addObject:asset];
                    
                    _mediaList = [NSMutableArray arrayWithArray:[_mediaList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        NSDate *date1 = [obj1 valueForProperty:ALAssetPropertyDate];
                        NSDate *date2 = [obj2 valueForProperty:ALAssetPropertyDate];
                        return -[date1 compare:date2];
                    }]];
                    
                    [_collectionView.backgroundView setHidden:_mediaList.count>0];
                    [_collectionView reloadData];
                }
            }];
        }
    
    } failureBlock:^(NSError *error) {
        NSLog(@"No groups");
    }];
    
    

}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mediaList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PMMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    if ([[_mediaList objectAtIndex:indexPath.row] isMemberOfClass:[ALAsset class]])
    {
        ALAsset *media = [_mediaList objectAtIndex:indexPath.row];
        UIImage *image =  [PMPhotoManager getImageFromAsset:media type:ASSET_PHOTO_THUMBNAIL];
        
        [cell setImage:image];
    }
    
    
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ALAsset *media = [_mediaList objectAtIndex:indexPath.row];
    
    ALAssetRepresentation *rep = [media defaultRepresentation];
    long long filesize = [rep size];
    NSMutableData *rawData = [NSMutableData dataWithLength:(NSUInteger) filesize];
    void *buf = [rawData mutableBytes];
    NSError *error = nil;
    [rep getBytes:buf fromOffset:0 length:(NSUInteger)filesize error:&error];
    if(error)
    {
        [AlertManager showErrorMessage:@"File write error!"];
        return;
    }
    else
    {
        NSString *filename = [rep filename];
        NSString *filepath = [[PMFileManager MobileDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@", filename]];
        
        [rawData writeToFile:filepath atomically:YES];
        
        PMFileItem *item = [[PMFileItem alloc] init];
        
        item.name = filename;
        item.path = filepath;
        item.fullpath = filepath;
        
        NSError *error;
        NSDictionary<NSString *,id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&error];
        
        if(error==nil)
        {
            item.size = [attributes fileSize];
            item.modifiedTime = [attributes fileModificationDate];
            item.isDirectory = [[attributes fileType] isEqualToString:NSFileTypeDirectory];
            item.type = [attributes fileType];
        }
        
        PMLocalFileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileViewController"];
        controller.fileitem = item;
        
        controller.isSelecting = self.isSelecting;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

@end
