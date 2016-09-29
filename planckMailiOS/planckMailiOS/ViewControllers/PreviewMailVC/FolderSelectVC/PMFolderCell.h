//
//  PMFolderCell.h
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMFolderCell : UITableViewCell

-(void)bindData:(NSDictionary*)data selected:(BOOL)selected;
@end
