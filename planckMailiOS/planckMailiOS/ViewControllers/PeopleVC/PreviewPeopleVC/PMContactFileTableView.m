//
//  PMContactFileTableView.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactFileTableView.h"
#import "PMContactFileCell.h"
#import "PMFileFilterCell.h"
#import "Config.h"
#import "PMFileManager.h"
#import "UITableView+BackgroundText.h"


@interface PMContactFileTableView() <UITableViewDataSource, UITableViewDelegate, PMFileFilterCellDelegate>
{
    BOOL isFilter;
    NSString *filterName;
    
    NSMutableArray *filteredFiles;
    
    UILabel *emptyMessageLabel;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
@implementation PMContactFileTableView

+ (instancetype)createWithModel:(PMContactModel *)model
{
    PMContactFileTableView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if ([view isKindOfClass:[self class]]){
        view.model = model;
        return view;
    } else {
        return nil;
    }
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    filteredFiles = [NSMutableArray new];
    
    _tableView.backgroundView.hidden = NO;
}


-(void)setModel:(PMContactModel *)model
{
    _model = model;
    
    [_tableView showEmptyMessage:[NSString stringWithFormat:@"You have no files in your email from %@", [_model.name isEqual:[NSNull null]] || _model.name.length==0 ? _model.email : _model.name]];
}
-(void)setFiles:(NSArray *)files
{
    _files = files;
    
    if(_files.count > 0)
    {
        _tableView.backgroundView.hidden = YES;
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) return 30;
    else return 60;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *name = self.model.name;
    if(!name || [name isEqual:[NSNull null]] || name.length==0) name = self.model.email;
    
    
    NSInteger fileCnt = 0;
    
    if(isFilter)
        fileCnt = filteredFiles.count+1;
    else
        fileCnt = _files.count+1;
    
    return fileCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
    {
        PMFileFilterCell *filterCell = (PMFileFilterCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMFileFilterCell class])];;
        if(!filterCell) {
            filterCell = [PMFileFilterCell newCell];
        }
        
        filterCell.lblFilterName.text = filterName;
        filterCell.delegate = self;
        
        return filterCell;
    }
    else
    {
        PMContactFileCell *fileCell = (PMContactFileCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMContactFileCell class])];;
        if(!fileCell) {
            fileCell = [PMContactFileCell newCell];
        }
        
        NSDictionary *file;
        if(isFilter)
        {
            file = filteredFiles[indexPath.row-1];
        }
        else
        {
            file = _files[indexPath.row-1];
        }
        
        [fileCell bindModel:file];
        return fileCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) return;
    
    NSDictionary *file;
    if(isFilter)
        file = [filteredFiles objectAtIndex:indexPath.row-1];
    else
        file = [self.files objectAtIndex:indexPath.row-1];    
    
    if([self.delegate respondsToSelector:@selector(didSelectFile:)])
        [self.delegate didSelectFile:file];
}



#pragma PMFileFilterCellDelegate
-(void)didFilterButtonPressed:(id)sender
{
    PMFileFilterCell *cell = (PMFileFilterCell*)sender;
    CGRect btnRect = cell.btnFilter.frame;
    CGRect fromRect = CGRectMake(btnRect.origin.x, _tableView.frame.origin.y+btnRect.origin.y, btnRect.size.width, btnRect.size.height);
    
    [cell showFilterMenu:self fromRect:fromRect];
}

- (void)didSelectFilterMenu:(NSString *)menuTitle
{
    
    if([menuTitle isEqualToString:@"all"])
    {
        isFilter = NO;
        filterName = @"";
    }
    else
    {
        isFilter = YES;
        filterName = menuTitle;
        
        [self filterFilesWithType:menuTitle];
    }
    
    [_tableView reloadData];
}

-(void)filterFilesWithType:(NSString*)type
{
    [filteredFiles removeAllObjects];
    
    if(!filteredFiles) filteredFiles = [NSMutableArray new];
    for(NSDictionary *file in _files)
    {
        if([PMFileManager IsEqualToType:type filename:file[@"filename"]])
            [filteredFiles addObject:file];        
    }
}

@end
