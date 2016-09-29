//
//  PMContactMailTableView.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactMailTableView.h"
#import "PMContactMailCell.h"
#import "PMContactMailVC.h"
#import "Config.h"
#import "UITableView+BackgroundText.h"

@interface PMContactMailTableView() <UITableViewDataSource, UITableViewDelegate, PMContactMailCellDelegate>
{
    UILabel *emptyMessageLabel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
@implementation PMContactMailTableView

+ (instancetype)createWithModel:(PMContactModel *)model
{
    PMContactMailTableView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if ([view isKindOfClass:[self class]]){
        view.model = model;
        return view;
    } else {
        return nil;
    }
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    _tableView.backgroundView.hidden = NO;
    
}

-(void)setModel:(PMContactModel *)model
{
    _model = model;
    
    NSString *name = self.model.name;
    if(!name || [name isEqual:[NSNull null]] || name.length==0) name = self.model.email;
    
    [_tableView showEmptyMessage:[NSString stringWithFormat:@"You have no email in your inbox  with %@", name]];
}
-(void)setMessages:(NSArray *)messages
{
    _messages = messages;
    if(_messages.count > 0)
    {
        _tableView.backgroundView.hidden = YES;
        [self.tableView reloadData];
    }
}
#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 109;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PMContactMailCell *cell = (PMContactMailCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMContactMailCell class])];
    if(!cell) {
        cell = [PMContactMailCell newCell];
    }
    
    NSDictionary *lItem = self.messages[indexPath.row];
    
    [cell bindModel:lItem email:_model.email];
    cell.delegate = self;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *message = [self.messages objectAtIndex:indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(didSelectMessage:)])
        [self.delegate didSelectMessage:message];
}

-(void)didSelectAttachment:(NSDictionary *)file
{
//    PMFilePreviewViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMFilePreviewViewController"];
//    
//    controller.file = file;
//    
//    [self.navigationController pushViewController:controller animated:YES];
    
    if([self.delegate respondsToSelector:@selector(didSelectAttachment:)])
        [self.delegate didSelectAttachment:file];
}

@end
