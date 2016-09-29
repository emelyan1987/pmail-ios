//
//  PMBoxFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEvernoteNoteListViewController.h"
#import "AlertManager.h"
#import "PMEvernoteNoteViewController.h"

@interface PMEvernoteNoteListViewController ()

@property (nonatomic, readwrite, strong) NSArray *items;
@property NSMutableArray *filteredItems;
@property NSMutableDictionary *thumbnails;

@end

@implementation PMEvernoteNoteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.thumbnails = [NSMutableDictionary new];
    [self loadItems];
    
    
    
    
    NSString *title = @"Your Evernote";
    [self setNavigationBar:title];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_EVERNOTE_ACCOUNT_DELETED object:nil];
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
    [AlertManager showProgressBarWithTitle:@"Loading..." view:self.view];
    
    
    __weak typeof(self) weakSelf = self;
//    [[ENSession sharedSession] listNotebooksWithCompletion:^(NSArray *notebooks, NSError *listNotebooksError) {
//        [AlertManager hideProgressBar];
//        if (listNotebooksError) {
//            [AlertManager showErrorMessage:[listNotebooksError localizedDescription]];
//            return;
//        }
//        
//        weakSelf.items = notebooks;
//    }];
    
    [[ENSession sharedSession] findNotesWithSearch:nil
                                        inNotebook:nil
                                           orScope:ENSessionSearchScopeAll
                                         sortOrder:ENSessionSortOrderRecentlyCreated
                                        maxResults:0
                                        completion:^(NSArray *findNotesResults, NSError *findNotesError) {
                                            [AlertManager hideProgressBar];
                                            if (!findNotesResults) {
                                                if ([findNotesError.domain isEqualToString:ENErrorDomain] &&
                                                    findNotesError.code == ENErrorCodePermissionDenied) {
                                                    [AlertManager showErrorMessage:@"Permission denied for note find. Maybe your app only has read access?"];
                                                } else {
                                                    [AlertManager showErrorMessage:@"Error searching for notes"];
                                                }
                                                NSLog(@"findNotesError: %@", findNotesError);
                                            } else if (findNotesResults.count == 0) {
                                                [AlertManager showInfoMessage:@"No notes found."];
                                            } else {
                                                weakSelf.items = findNotesResults;
                                                [weakSelf.tblFileList reloadData];
                                            }
                                        }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFilter)
        return self.filteredItems.count;
    return self.items.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    PMFileViewCell *cell = [self.tblFileList dequeueReusableCellWithIdentifier:@"PMFileViewCellID"];
    if (cell == nil)
    {
        cell = [PMFileViewCell newCell];
    }
    
    ENSessionFindNotesResult *item;
    
    if(self.isFilter)
        item = self.filteredItems[indexPath.row];
    else
        item = self.items[indexPath.row];    
    
    
    cell.lblFileName.text = item.title;
    cell.lblModifiedTime.text = [PMFileManager RelativeTime:[item.updated timeIntervalSince1970]];
    cell.lblFileSize.hidden = YES;
    
    NSString *thumbnailPath = [[PMFileManager ThumbnailDirectory:@"Evernote"] stringByAppendingPathComponent:item.noteRef.guid];
    UIImage *knownThumbnail = [UIImage imageWithContentsOfFile:thumbnailPath];
    
    
    if (knownThumbnail) {
        cell.imgThumbnail.image = knownThumbnail;
    } else {
        __weak PMFileViewCell *weakCell = cell;
        [[ENSession sharedSession] downloadThumbnailForNote:item.noteRef maxDimension:100 completion:^(UIImage *thumbnail, NSError *downloadNoteThumbnailError) {
            if (thumbnail) {
                NSData *imageData = UIImagePNGRepresentation(thumbnail);
                [imageData writeToFile:thumbnailPath atomically:YES];                

                // fade animation transition effect
                weakCell.imgThumbnail.image = thumbnail;
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [weakCell.imgThumbnail.layer addAnimation:transition forKey:nil];
            }
        }];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ENSessionFindNotesResult * result = self.items[indexPath.row];
    PMEvernoteNoteViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEvernoteNoteViewController"];
    vc.isSelecting = self.isSelecting;
    vc.noteRef = result.noteRef;
    vc.noteTitle = result.title;
    [self.navigationController pushViewController:vc animated:YES];
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
            ENSessionFindNotesResult *item = [_items objectAtIndex:i];
            
            
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
