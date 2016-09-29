//
//  PMPreviewTableView.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/10/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewTableView.h"

#import "PMPreviewMailTVCell.h"
#import "PMThread.h"
#import "MBProgressHUD.h"
#import "PMAPIManager.h"
#import <AFNetworking.h>
#import "PMTextManager.h"
#import "AlertManager.h"
#import "NSMutableArray+MessageDictionary.h"

@interface PMPreviewTableView () <UITableViewDataSource, UITableViewDelegate, PMPreviewMailTVCellDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIButton *unsubscribeBtn;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet NSLayoutConstraint *unsubscribeBtnHeightConstraint;
    
    __weak IBOutlet UIView *actionView;
    __weak IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
    
    NSMutableArray *_expandedCellIndexArray;  //expanded cell array
    NSMutableDictionary *_cellHeightArray;
    NSMutableDictionary *_cellViewMoreArray;
    
    NSMutableArray *_cells;
    
    BOOL loadedContent;
    
    PMPreviewMailTVCell *lastMailCell;
}

@end

@implementation PMPreviewTableView

+ (instancetype)newPreviewView {
    NSArray *previewViewes = [[NSBundle mainBundle] loadNibNamed:@"PMPreviewTableView" owner:nil options:nil];
    return [previewViewes firstObject];
}

#pragma mark - Init

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    actionView.layer.cornerRadius = 16;
    
    _expandedCellIndexArray = [NSMutableArray new];
    _cellHeightArray = [NSMutableDictionary new];
    
    _cells = [NSMutableArray new];
}



#pragma mark - Properties

- (void)setInboxMailModel:(PMThread *)inboxMailModel {
    _inboxMailModel = inboxMailModel;
    
    _titleLabel.text = _inboxMailModel.subject;
    
    
    
    BOOL isClutter = NO;    
    
    for(NSDictionary *folder in inboxMailModel.folders) {
        if([[folder[@"display_name"] lowercaseString] isEqualToString:@"read later"])
            isClutter = YES;
    }
    
    unsubscribeBtn.hidden = NO;//!isClutter;
        
    headerView.frame = ({
        CGFloat lHeight = [self getLabelHeight:_titleLabel];
        CGRect lRect = headerView.frame;
        lRect.size.height = lHeight + 16 + 20;//(isClutter?20:0);
        lRect;
    });
    
    _tableView.tableHeaderView = headerView;
    
    if(!self.messages)
    {
        NSArray *localMessages = [[PMAPIManager shared] getMessagesWithThreadId:_inboxMailModel.id forAccount:_inboxMailModel.accountId completion:^(id data, id error, BOOL success) {
            if (success) {
                DLog(@"data - %@", data);
                
                BOOL isRequireUpdate = NO;
                for(NSDictionary *msg in data)
                {
                    if(![self.messages containsMessageWithId:msg[@"id"]])
                    {
                        [self.messages addObject:msg];
                        isRequireUpdate = YES;
                    }
                }
                
                if(isRequireUpdate)
                {
                    [_cells removeAllObjects];
                    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
                    [self.messages sortUsingDescriptors:sortDescriptors];
                    
                    for(NSInteger i=0; i<self.messages.count; i++)
                    {
                        NSDictionary *msg = [self.messages objectAtIndex:i];
                        PMPreviewMailTVCell *cell = [PMPreviewMailTVCell newCell];
                        cell.tag = i;
                        cell.delegate = self;
                        
                        [cell updateCellWithInfo:msg expanded:YES];
                        
                        if(i == self.messages.count-1)
                        {
                            [_expandedCellIndexArray addObject:@(i)];
                            
                            NSInteger height;
                            height = self.frame.size.height - headerView.frame.size.height + 500;
                            [_cellHeightArray setObject:@(height) forKey:@(i)];
                            
                            [cell expand];
                        }
                        else
                        {
                            [cell collapse];
                        }
                        
                        
                        
                        [_cells addObject:cell];
                        
                    }
                    
                    [_tableView reloadData];
                    
                    if(self.messages.count>2)
                    {
                        CGFloat height;
                        height = headerView.frame.size.height + (78+9)*(self.messages.count-2);
                        [_tableView setContentOffset:CGPointMake(0, height)];
                    }
                }
            }
        }];
        
        
        self.messages = [NSMutableArray arrayWithArray:localMessages];
        if(self.messages.count>0)
        {
            NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
            [self.messages sortUsingDescriptors:sortDescriptors];
            
            
            for(NSInteger i=0; i<self.messages.count; i++)
            {
                NSDictionary *msg = [self.messages objectAtIndex:i];
                PMPreviewMailTVCell *cell = [PMPreviewMailTVCell newCell];
                cell.tag = i;
                cell.delegate = self;
                [cell updateCellWithInfo:msg expanded:[_expandedCellIndexArray containsObject:@(i)]];
                
                [_cells addObject:cell];
                
                
                if(i == self.messages.count-1)
                {
                    [_expandedCellIndexArray addObject:@(i)];
                    
                    NSInteger height;
                    height = self.frame.size.height - headerView.frame.size.height + 500;
                    [_cellHeightArray setObject:@(height) forKey:@(i)];
                }
                
            }
            
            [_tableView reloadData];
            
            if(self.messages.count>2)
            {
                CGFloat height;
                height = headerView.frame.size.height + (78+9)*(self.messages.count-2);
                [_tableView setContentOffset:CGPointMake(0, height)];
            }
            
            
        }
        
        
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        CGRect actionViewFrame  = actionView.frame;
        
        actionView.frame = CGRectMake(actionViewFrame.origin.x, actionViewFrame.origin.y-50, actionViewFrame.size.width, actionViewFrame.size.height);
        
        actionViewBottomConstraint.constant = self.frame.size.height - actionView.frame.origin.y - actionView.frame.size.height;
    }];
}

- (void)updateMessages {
    if([self.delegate respondsToSelector:@selector(PMPreviewTableView:didUpdateMessages:)]) {
        [self.delegate PMPreviewTableView:self didUpdateMessages:self.messages];
    }
    
    [_tableView reloadData];
    
}

- (IBAction)notifyAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(PMPreviewTableViewDelegateShowAlert:inboxMailModel:)]) {
        [_delegate PMPreviewTableViewDelegateShowAlert:self inboxMailModel:self.inboxMailModel];
    }
    
}
- (IBAction)unsubscribeButtonClicked:(id)sender {
    if([_delegate respondsToSelector:@selector(didTapUnsubscribeButton:model:)])
        [_delegate didTapUnsubscribeButton:self model:_inboxMailModel];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _messages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([_expandedCellIndexArray containsObject:@(indexPath.section)])
//        return [[_cellHeightArray objectForKey:@(indexPath.section)] integerValue];
    
    //return 78;
    
    NSInteger index = indexPath.section;
    PMPreviewMailTVCell *cell = _cells[index];
    
    CGFloat height = [cell height:[_expandedCellIndexArray containsObject:@(indexPath.section)]];
    return height;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.section;
    
    PMPreviewMailTVCell *cell = [_cells objectAtIndex:index];
    
    if([_expandedCellIndexArray containsObject:@(indexPath.section)])
    {
        //cell.expanded = YES;
        
        [cell expand];
    }
    else
    {
        //cell.expanded = NO;
        [cell collapse];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMPreviewMailTVCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell toggled]) return;
    [self expandOrCollapseWithIndexPath:indexPath];
}

-(void)expandOrCollapseWithIndexPath:(NSIndexPath *)indexPath
{
    if ([_expandedCellIndexArray containsObject:@(indexPath.section)]) {
        [_expandedCellIndexArray removeObject:@(indexPath.section)];
    } else {
        [_expandedCellIndexArray addObject:@(indexPath.section)];
        
        //[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    //[_tableView beginUpdates];
    //[_tableView endUpdates];
    [_tableView reloadData];
}


-(void)expandAll
{
    for(int i=0; i<_messages.count; i++)
    {
        if (![_expandedCellIndexArray containsObject:@(i)]) {
            [_expandedCellIndexArray addObject:@(i)];
        }
    }
    
    
    [_tableView reloadData];
    
}
#pragma mark - Private methods

- (CGFloat)getLabelHeight:(UILabel*)label {
    CGSize constraint = CGSizeMake(label.frame.size.width, 20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (IBAction)btnFlagClicked:(id)sender {
    if([_delegate respondsToSelector:@selector(didTapBtnFlag:thread:)])
        [_delegate didTapBtnFlag:sender thread:_inboxMailModel];
}

- (IBAction)btnExpandClicked:(id)sender {
    
        [self expandAll];
}
- (IBAction)btnSummaryClicked:(id)sender {
    
    NSMutableString *snippedString = [[NSMutableString alloc] init];
    for(NSDictionary *msg in _messages)
    {
        [snippedString appendString:[NSString stringWithFormat:@"%@\n\n", msg[@"snippet"]]];
    }
    [self.delegate onGystAction:self.messages];
}

#pragma mark - PMPreviewMailTVCellDelegate

-(void)didSelectAttachment:(NSDictionary *)file
{
    [_delegate didSelectAttachment:file];
}
-(void)didChangedCellHeight:(PMPreviewMailTVCell *)cell
{
//    CGFloat height = [cell height:cell.expanded];
//    [_cellHeightArray setObject:[NSNumber numberWithInteger:height] forKey:[NSNumber numberWithInteger:cell.tag]];
//
//    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:cell.tag]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadData];
}

-(void)didTapOnEmail:(NSString *)email name:(NSString*)name sender:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTapOnEmail:name:sender:)])
        [self.delegate didTapOnEmail:email name:name sender:sender];
}
-(void)didTapBtnRSVP:(UIButton *)sender eventId:(NSString *)eventId
{
    if([self.delegate respondsToSelector:@selector(didTapBtnRSVP:eventId:)])
        [self.delegate didTapBtnRSVP:sender eventId:eventId];
        
}
- (void)didTapBtnMore:(PMPreviewMailTVCell *)cell
{
    [_cellViewMoreArray setObject:@(YES) forKey:@(cell.tag)];
    
    
    [_tableView reloadData];
}

- (void)didTapBtnLess:(PMPreviewMailTVCell *)cell
{
    [_cellViewMoreArray setObject:@(NO) forKey:@(cell.tag)];
    //[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:cell.tag]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didTapBtnReply:(UIButton *)sender messageData:(NSDictionary *)data
{
    if([self.delegate respondsToSelector:@selector(didTapBtnReply:messageData:)])
        [self.delegate didTapBtnReply:sender messageData:data];
}
@end
