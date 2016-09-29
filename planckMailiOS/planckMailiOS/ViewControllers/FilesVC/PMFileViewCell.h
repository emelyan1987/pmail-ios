//
//  PMFileViewCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMFileViewCell : UITableViewCell

+ (instancetype)newCell;

@property (weak, nonatomic) IBOutlet UILabel *lblFileName;

@property (weak, nonatomic) IBOutlet UILabel *lblModifiedTime;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnail;
@end
