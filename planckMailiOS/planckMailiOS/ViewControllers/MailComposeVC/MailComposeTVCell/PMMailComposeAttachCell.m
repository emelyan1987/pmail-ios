//
//  PMMailComposeAttachCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/2/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeAttachCell.h"
#import "PMFileManager.h"

@interface PMMailComposeAttachCell()
@property NSDictionary *file;
@end
@implementation PMMailComposeAttachCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(NSString *)filepath uploadStatus:(NSNumber *)uploadStatus
{
    NSMutableDictionary *file = [[NSMutableDictionary alloc] init];
    
    NSString *filename = [filepath lastPathComponent];
    NSString *filesize;
    
    [file setObject:filepath forKey:@"filepath"];
    [file setObject:filename forKey:@"filename"];
    
    NSError *error;
    NSDictionary<NSString *,id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&error];
    
    if(error==nil)
    {
        long long lFileSize = [attributes fileSize];
        filesize = [PMFileManager FileSizeAsString:lFileSize];
        
        [file setObject:filesize forKey:@"filesize"];
        
        if(lFileSize > 25*1024*1024)
        {
            self.lblStatus.text = @"Exceed 25MB";
        }
        else
        {
            self.lblStatus.text = @"";
        }
    }
    
    UIImage *icon = [UIImage imageNamed:[PMFileManager IconFileByExt:[filename pathExtension]]];
    
    
    if([PMFileManager IsThumbnailAbaliable:filename])
    {
        UIImage *thumbnail = [PMFileManager ThumbnailFromFile:filepath];
        if(thumbnail)
            icon = thumbnail;
    }
    
    self.lblFileName.text = filename;
    self.lblFileSize.text = filesize;
    self.imgIcon.image = icon;
    
    self.file = file;
    
    if(!uploadStatus || [uploadStatus integerValue]==PMFileUploadStatusSucceeded)
        self.lblStatus.text = @"";
    else if([uploadStatus integerValue]==PMFileUploadStatusFailed)
        self.lblStatus.text = @"Failed";
    
}
- (IBAction)btnDeleteClicked:(id)sender {
    [self.delegate didClickAttachDeleteButton:[self.file objectForKey:@"filepath"]];
}
@end
