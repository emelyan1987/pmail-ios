//
//  PMFileFilterCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMMailFilterCell.h"

#import "KxMenu.h"

@implementation PMMailFilterCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMMailFilterCell" owner:nil options:nil];
    PMMailFilterCell *cell = [cellsXIB firstObject];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblFilterName.text = @"";
    return cell;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)btnFilterPressed:(id)sender {
    [self.delegate didFilterButtonPressed:self];
}

-(void)showFilterMenu:(UIView *)view fromRect:(CGRect)rect
{
    KxMenuItem *menuAll = [KxMenuItem menuItem:@"all"
                                         image:nil
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuUnread = [KxMenuItem menuItem:@"unread"
                                           image:[UIImage imageNamed:@"menu_unread"]
                                          target:self
                                          action:@selector(pushFilterItem:)];
    KxMenuItem *menuFlagged = [KxMenuItem menuItem:@"flagged"
                                         image:[UIImage imageNamed:@"menu_flagged"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuAttachments = [KxMenuItem menuItem:@"attachments"
                                         image:[UIImage imageNamed:@"menu_attachments"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    
    NSArray *menuItems =
    @[menuAll, menuUnread, menuFlagged, menuAttachments];
    
    menuAll.foreColor = [UIColor darkGrayColor];
    menuAll.alignment = NSTextAlignmentJustified;
    
    menuUnread.foreColor = [UIColor darkGrayColor];
    menuUnread.alignment = NSTextAlignmentJustified;
    
    menuFlagged.foreColor = [UIColor darkGrayColor];
    menuFlagged.alignment = NSTextAlignmentJustified;
    
    menuAttachments.foreColor = [UIColor darkGrayColor];
    menuAttachments.alignment = NSTextAlignmentJustified;
    
    //[KxMenu setTintColor:[UIColor whiteColor]];
    
    
    [KxMenu showMenuInView:view
                  fromRect:rect
                 menuItems:menuItems];
}

- (void) pushFilterItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem*)sender;
    
    NSString *title = item.title;
    
    [self.delegate didSelectFilterMenu:title];
}
@end
