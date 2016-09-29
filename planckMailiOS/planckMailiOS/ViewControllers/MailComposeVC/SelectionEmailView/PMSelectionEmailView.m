//
//  PMSelectionEmailView.m
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSelectionEmailView.h"

#define VIEW_ANIMATION 0.25f
#define CONTENT_VIEW_TOP_LANDSCAPE 32
#define CONTENT_VIEW_TOP_PORTRAIT 75

#define KEY_WINDOW ((UIWindow*)[[[UIApplication sharedApplication] windows] objectAtIndex:0])

@interface PMSelectionEmailView () <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIView *_contentView;
    __weak IBOutlet UIView *_tapView;
    
    IBOutlet NSLayoutConstraint *_contentViewConstrainTop;
    
    NSArray *_itemsArray;
}
@end

@implementation PMSelectionEmailView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *lTapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler)];
    [_tapView addGestureRecognizer:lTapGestureRecognize];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    _contentView.layer.cornerRadius = 10;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Private methods

- (void)showInView:(UIView *)view {
    self.frame = view.frame;
    _tapView.backgroundColor = [UIColor clearColor];
    
    [KEY_WINDOW addSubview:self];
    
    _contentViewConstrainTop.constant = -_contentView.frame.size.height;
    [self layoutIfNeeded];
    
   UIDevice *lDevice = [UIDevice currentDevice];
    
    if (lDevice.orientation == UIDeviceOrientationLandscapeLeft || lDevice.orientation == UIDeviceOrientationLandscapeRight) {
        _contentViewConstrainTop.constant = CONTENT_VIEW_TOP_LANDSCAPE;
    } else {
        _contentViewConstrainTop.constant = CONTENT_VIEW_TOP_PORTRAIT;
    }
    
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:VIEW_ANIMATION animations:^{
        [self layoutIfNeeded];
        _tapView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
    }];
}

- (void)hide {
    _contentViewConstrainTop.constant = - _contentView.frame.size.height;
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:VIEW_ANIMATION animations:^{
        [self layoutIfNeeded];
        _tapView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapHandler {
    [self hide];
}

- (void)setEmails:(NSArray *)emails {
    _itemsArray = emails;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    UIDevice *lDevice = notification.object;
    
    if (lDevice.orientation == UIDeviceOrientationLandscapeLeft || lDevice.orientation == UIDeviceOrientationLandscapeRight) {
        _contentViewConstrainTop.constant = CONTENT_VIEW_TOP_LANDSCAPE;
    } else {
        _contentViewConstrainTop.constant = CONTENT_VIEW_TOP_PORTRAIT;
    }
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

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (lCell == nil) {
        lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *lEmail = [_itemsArray objectAtIndex:indexPath.row];
    
    lCell.textLabel.text = lEmail;
    
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *lEmail = [_itemsArray objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(PMSelectionEmailViewDelegate:didSelectEmail:)]) {
        [_delegate PMSelectionEmailViewDelegate:self didSelectEmail:lEmail];
    }
    [self hide];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell];
}

@end
