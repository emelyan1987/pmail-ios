//
//  PMFileViewCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileViewCell.h"

@implementation PMFileViewCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMFileViewCell" owner:nil options:nil];
    PMFileViewCell *cell = [cellsXIB firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
