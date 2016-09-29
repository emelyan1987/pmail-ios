//
//  PMFolderCell.m
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMFolderCell.h"
#import "Config.h"

@interface PMFolderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation PMFolderCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;    
    
}



- (void)bindData:(NSDictionary *)data selected:(BOOL)selected
{
    NSString *displayName = data[@"display_name"];
    NSString *name = data[@"name"];
    
    self.lblTitle.text = displayName;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_menu_icon%@", [name lowercaseString], selected?@"_selected":@""]];
    
    if(!img)
        img = [UIImage imageNamed:[NSString stringWithFormat:@"folder_menu_icon%@",selected?@"_selected":@""]];
    self.imgViewIcon.image = img;
    
    if(selected)
    {
        _lblTitle.textColor = UIColorFromRGB(0x30c4b4);
    }
    else
    {
        _lblTitle.textColor = UIColorFromRGB(0x9f9f9f);
    }
}
@end
