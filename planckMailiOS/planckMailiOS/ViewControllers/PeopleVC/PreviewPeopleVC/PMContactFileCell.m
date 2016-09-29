//
//  PMAttachmentCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactFileCell.h"
#import "PMFileManager.h"



@implementation PMContactFileCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMContactFileCell" owner:nil options:nil];
    PMContactFileCell *cell = [cellsXIB firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(NSDictionary *)model
{
    NSString *filename = [model[@"filename"] isEqual:[NSNull null]] || ((NSString*)model[@"filename"]).length==0 ? @"(Untitled)" : model[@"filename"];
    NSString *iconName = [PMFileManager IconFileByExt:[filename pathExtension]];
    UIImage *icon = [UIImage imageNamed:iconName];
    
    self.imgIcon.image = icon;
    self.lblFileName.text = filename;
    self.lblFileSize.text = [PMFileManager FileSizeAsString:[model[@"size"] longLongValue]];
    
    self.lblModifiedTime.text = [PMFileManager RelativeTime:[model[@"date"] doubleValue]];
}
@end
