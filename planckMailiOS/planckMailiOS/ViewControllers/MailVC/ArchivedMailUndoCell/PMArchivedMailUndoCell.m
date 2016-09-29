//
//  PMArchivedMailUndoCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/5/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMArchivedMailUndoCell.h"

@implementation PMArchivedMailUndoCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMArchivedMailUndoCell" owner:nil options:nil];
    PMArchivedMailUndoCell *cell = [cellsXIB firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)btnArchivedTap:(id)sender
{
    if (self.archivedButtonTapAction) {
        self.archivedButtonTapAction(sender);
    }
}
- (IBAction)btnUndoTap:(id)sender
{
    if (self.undoButtonTapAction) {
        self.undoButtonTapAction(sender);
    }
}

@end
