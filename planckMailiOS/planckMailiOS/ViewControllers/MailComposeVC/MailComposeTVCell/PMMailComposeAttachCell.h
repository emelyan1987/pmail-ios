//
//  PMMailComposeAttachCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/2/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PMFileUploadStatusSucceeded,
    PMFileUploadStatusFailed
} PMFileUploadStatus;


@protocol PMMailComposeAttachCellDelegate <NSObject>
- (void)didClickAttachDeleteButton:(NSString *)filepath;
@end

@interface PMMailComposeAttachCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

-(void)bindModel:(NSString *)filepath uploadStatus:(NSNumber*)uploadStatus;

@property(nonatomic, weak) id<PMMailComposeAttachCellDelegate> delegate;
@end
