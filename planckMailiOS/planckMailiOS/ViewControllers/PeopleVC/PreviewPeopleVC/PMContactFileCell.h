//
//  PMAttachmentCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMContactFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UILabel *lblModifiedTime;

+ (instancetype)newCell;

-(void)bindModel:(NSDictionary*)model;


@end
