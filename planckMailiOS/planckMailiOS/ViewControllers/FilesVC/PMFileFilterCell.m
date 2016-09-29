//
//  PMFileFilterCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileFilterCell.h"

#import "KxMenu.h"

@implementation PMFileFilterCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMFileFilterCell" owner:nil options:nil];
    PMFileFilterCell *cell = [cellsXIB firstObject];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    KxMenuItem *menuImage = [KxMenuItem menuItem:@"images"
                                           image:[UIImage imageNamed:@"menu_image"]
                                          target:self
                                          action:@selector(pushFilterItem:)];
    KxMenuItem *menuDoc = [KxMenuItem menuItem:@"docs"
                                         image:[UIImage imageNamed:@"menu_doc"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuPpt = [KxMenuItem menuItem:@"slides"
                                         image:[UIImage imageNamed:@"menu_ppt"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuPdf = [KxMenuItem menuItem:@"pdfs"
                                         image:[UIImage imageNamed:@"menu_pdf"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    KxMenuItem *menuZip = [KxMenuItem menuItem:@"zip files"
                                         image:[UIImage imageNamed:@"menu_zip"]
                                        target:self
                                        action:@selector(pushFilterItem:)];
    
    NSArray *menuItems =
    @[menuAll, menuImage, menuDoc, menuPpt, menuPdf, menuZip];
    
    menuAll.foreColor = [UIColor darkGrayColor];
    menuAll.alignment = NSTextAlignmentCenter;
    
    menuImage.foreColor = [UIColor darkGrayColor];
    menuImage.alignment = NSTextAlignmentCenter;
    
    menuDoc.foreColor = [UIColor darkGrayColor];
    menuDoc.alignment = NSTextAlignmentCenter;
    
    menuPpt.foreColor = [UIColor darkGrayColor];
    menuPpt.alignment = NSTextAlignmentCenter;
    
    menuPdf.foreColor = [UIColor darkGrayColor];
    menuPdf.alignment = NSTextAlignmentCenter;
    
    menuZip.foreColor = [UIColor darkGrayColor];
    menuZip.alignment = NSTextAlignmentCenter;
    
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
