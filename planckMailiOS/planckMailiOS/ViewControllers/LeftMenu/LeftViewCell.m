//
//  PMFolderCell.m
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "LeftViewCell.h"
#import "Config.h"

@interface LeftViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;

@end

@implementation LeftViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.lblTitle.font = [UIFont fontWithName:@"Helvetica" size:16.f];
    
    //self.lblCount.layer.cornerRadius = self.lblCount.frame.size.height/2;
    //self.lblCount.clipsToBounds = YES;
    // -----
    
    //    _separatorView = [UIView new];
    //    [self addSubview:_separatorView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //self.lblTitle.textColor = _tintColor;
    //self.lblCount.textColor = _tintColor;
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (highlighted)
//    {
//        UIColor *highlightColor = UIColorFromRGB(0x30c4b4);
//        self.lblTitle.textColor = highlightColor;
//        self.lblCount.textColor = highlightColor;
//    }
//    else
//    {
//        self.lblTitle.textColor = UIColorFromRGB(0x9f9f9f);
//        self.lblCount.textColor = UIColorFromRGB(0x9f9f9f);
//    }
//}

- (void)bindData:(NSDictionary *)data selected:(BOOL)selected
{
    NSString *displayName = data[@"display_name"];
    NSString *name = data[@"name"];
    
    self.lblTitle.text = displayName;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_menu_icon%@", [name lowercaseString], selected?@"_selected":@""]];
    
    if(!img)
        img = [UIImage imageNamed:[NSString stringWithFormat:@"folder_menu_icon%@",selected?@"_selected":@""]];
    self.imgViewIcon.image = img;
    
    NSNumber *count = data[@"unreads"];
    
    if(count && [count intValue]>0)
    {
        self.lblCount.hidden = NO;
        self.lblCount.text = [NSString stringWithFormat:@" %@ ", [count stringValue]];
    }
    else
    {
        self.lblCount.hidden = YES;
    }
    //self.tintColor = [UIColor whiteColor];
    if(selected)
    {
        _lblTitle.textColor = UIColorFromRGB(0x30c4b4);
    }
    else
    {
        _lblTitle.textColor = UIColorFromRGB(0x9f9f9f);
    }
}

- (void)setSelected:(BOOL)selected {
    
    
}
@end
