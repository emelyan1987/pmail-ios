//
//  AlbumTableViewController.h
//  Waffer
//
//  Created by Henry on 7/2/15.
//  Copyright (c) 2015 matko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMAlbumViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL isSelecting; // if is picking photo?
@end
