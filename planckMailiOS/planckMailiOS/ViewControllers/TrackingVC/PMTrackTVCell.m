//
//  PMTrackTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMTrackTVCell.h"

@interface PMTrackTVCell()
@property (weak, nonatomic) IBOutlet UILabel *lblSubject;
@property (weak, nonatomic) IBOutlet UILabel *lblEmails;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblOpens;
@property (weak, nonatomic) IBOutlet UILabel *lblClicks;
@property (weak, nonatomic) IBOutlet UILabel *lblReplies;

@end
@implementation PMTrackTVCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindData:(NSDictionary *)trackData
{
    _lblSubject.text = trackData[@"subject"]&&((NSString*)trackData[@"subject"]).length?trackData[@"subject"]:@"(No Subject)";
    _lblEmails.text = trackData[@"target_emails"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    _lblDate.text = trackData[@"modified_time"];
    
    _lblOpens.text = trackData[@"opens"]&&![trackData[@"opens"] isEqual:[NSNull null]]?[trackData[@"opens"] stringValue]:nil;
    _lblClicks.text = trackData[@"links"]&&![trackData[@"links"] isEqual:[NSNull null]]?[trackData[@"links"] stringValue]:nil;
    _lblReplies.text = trackData[@"replies"]&&![trackData[@"replies"] isEqual:[NSNull null]]?[trackData[@"replies"] stringValue]:nil;
}
@end
