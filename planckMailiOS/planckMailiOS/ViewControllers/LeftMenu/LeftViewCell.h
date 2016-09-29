//
//  PMFolderCell.h
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewCell : UITableViewCell

@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIColor *tintColor;



-(void)bindData:(NSDictionary*)data selected:(BOOL)selected;
@end
