//
//  PMFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PMFileViewCell.h"
#import "PMFileManager.h"
#import "PMFileItem.h"
#import "PMFileFilterCell.h"

@interface PMFileListViewController : UIViewController <UITableViewDelegate, PMFileFilterCellDelegate, UISearchBarDelegate>

@property BOOL isSelecting;
@property BOOL isFilter;
@property BOOL isSearch;
@property NSString *filterName;
@property NSString *searchText;

@property (weak, nonatomic) IBOutlet UITableView *tblFileList;
-(void) setNavigationBar:(NSString*)title;
-(void) showLoadingProgressBar;
-(void) hideLoadingProgressBar;

-(void)processSearch:(NSString*)text;
- (void)selectFilterMenu:(NSString *)menuTitle;

@end
