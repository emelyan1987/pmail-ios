//
//  PMMailMenuView.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailMenuView.h"


#define KEY_WINDOW ((UIWindow*)[[[UIApplication sharedApplication] windows] objectAtIndex:0])
#define CELL_IDENTIFIER @"itemTVCell"
#define CELL_HEIGHT 65.0f

@interface PMMailMenuView () <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UIView *_contentView;
    __weak IBOutlet UIView *_tapView;
    __weak IBOutlet UITableView *_tableView;
    
    IBOutlet NSLayoutConstraint *_contentViewLeftPosition;
    
    NSArray *_itemsArray;
}
@end

@implementation PMMailMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *lTapGesureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler)];
    [_tapView addGestureRecognizer:lTapGesureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _itemsArray = [[DBManager instance] getNamespaces];
    
    NSIndexPath * lselectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView selectRowAtIndexPath:lselectedIndexPath
                           animated:NO
                     scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)showInView:(UIView *)view {
    self.frame = [UIScreen mainScreen].bounds;
    [KEY_WINDOW addSubview:self];
    
    _tapView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
    
    _contentViewLeftPosition.constant = - _contentView.frame.size.width;
    [self layoutIfNeeded];
    
    _contentViewLeftPosition.constant = 0;
    
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        _tapView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
        
        [self layoutIfNeeded];
    }];
}

- (void)hide {
    _contentViewLeftPosition.constant = -_contentView.frame.size.width;
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        _tapView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.0f];
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapHandler {
    [self hide];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    self.frame = [UIScreen mainScreen].bounds;
    [self layoutIfNeeded];
    [self updateConstraintsIfNeeded];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *lTableViewCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (lTableViewCell == nil) {
        lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    DBNamespace *lItemModel = [_itemsArray objectAtIndex:indexPath.row];
    
    lTableViewCell.textLabel.text = lItemModel.email_address;
    lTableViewCell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return lTableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_itemsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBNamespace *lSelectedNamespace = [_itemsArray objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(PMMailMenuViewSelectNamespace:)]) {
        [_delegate PMMailMenuViewSelectNamespace:lSelectedNamespace];
    }
    [self hide];
}

@end
