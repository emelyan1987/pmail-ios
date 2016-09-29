//
//  PMGystCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMGystCell.h"
#import "FTWCache.h"
#import "PMTextManager.h"
#import "PMAPIManager.h"
#import "NSString+Color.h"

@interface PMGystCell()
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UILabel *circleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnReadOriginal;
@property (weak, nonatomic) IBOutlet UIButton *btnReadSummary;
@property (strong, nonatomic) IBOutlet UIButton *btnReply;
@property (strong, nonatomic) IBOutlet UIButton *btnReplyAll;
@property (strong, nonatomic) IBOutlet UIButton *btnForward;

@property NSString* messageId;
@property NSDictionary *model;
@property NSIndexPath *indexPath;
@end
@implementation PMGystCell

- (void)awakeFromNib {
    // Initialization code
    
    _circleView.alpha = 0.8;
    _circleView.layer.cornerRadius = 25;
    _circleView.backgroundColor = [UIColor blueColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _messageLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(NSDictionary *)model showOriginal:(BOOL)showOriginal indexPath:(NSIndexPath *)indexPath
{
    _model = model;
    _indexPath = indexPath;
    
    NSString *name = model[@"from"][0][@"name"];
    NSString *email = model[@"from"][0][@"email"];
    
    _nameLabel.text = [name isEqual:[NSNull null]] || name.length == 0 ? email : name;
    
    
    _messageId = model[@"id"];
    [self setSummaryText:model[@"body"] messageId:_messageId showOriginal:showOriginal];
    
   
    
    // set color and label of circle view
    NSString *circleLabelText = [[NSString alloc] init];
    
    if([name isEqual:[NSNull null]] || name.length == 0)
    {
        circleLabelText = [[PMTextManager shared] getLabelLettersFromText:email];
    }
    else
    {
        circleLabelText = [[PMTextManager shared] getLabelLettersFromText:name];
    }
    
    _circleLabel.text = circleLabelText;
    
    
    CGFloat hue = [circleLabelText LabelColor];
    CGFloat saturation = 1.0;
    CGFloat brightness = 0.8;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    
    _circleView.backgroundColor = color;
    
    
    _btnReadOriginal.hidden = showOriginal;
    _btnReadSummary.hidden = !showOriginal;
    
    
    _btnReplyAll.hidden = YES;
    _btnReply.hidden = [email isEqualToString:[PMAPIManager shared].namespaceId.email_address];
}

-(void)setSummaryText:(NSString *)bodyHTML messageId:(NSString*)msgId showOriginal:(BOOL)bShowOriginal
{
    _messageLabel.text = @"\n";
    NSString *plainText = [[PMTextManager shared] convertHTML:bodyHTML];
    if(bShowOriginal)
    {
        [_messageLabel setText:plainText];
    }
    else
    {
        NSData *cacheData = [FTWCache objectForKey:msgId];
        NSArray *summaries = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
        
        NSMutableString *summary = [NSMutableString new];
        if(summaries!=nil)
        {
            for(NSString *str in summaries)
            {
                [summary appendString:[NSString stringWithFormat:@"%@\n",str]];
            }
            [_messageLabel setText:summary&&summary.length?summary:@"\n"];
        }
        else
        {
            NSInteger lines = [[PMTextManager shared] countOfLines:plainText];
            NSInteger length = lines * 25 / 100;
            length = length==0?lines:length;
            
            [[PMAPIManager shared] getSummariesFromText:plainText lines:length completion:^(id data, id error, BOOL success) {
                if(success)
                {
                    NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:data];
                    [FTWCache setObject:cacheData forKey:msgId];
                    
                    
                    for(NSString *str in data)
                    {
                        [summary appendString:[NSString stringWithFormat:@"%@\n",str]];
                    }
                    
                    [_messageLabel setText:summary&&summary.length?summary:@"\n"];
                }
            }];
        }
    }
}
- (IBAction)btnReadOriginalClicked:(id)sender {
    [self.delegate btnReadOriginalPressed:_indexPath];
}
- (IBAction)btnReadSummaryClicked:(id)sender {
    [self.delegate btnReadSummaryPressed:_indexPath];
}
- (IBAction)btnReplyClicked:(id)sender {
    [self.delegate btnReplyPressed:_indexPath];
}
- (IBAction)btnReplyAllClicked:(id)sender {
    [self.delegate btnReplyAllPressed:_indexPath];
}
- (IBAction)btnForwardClicked:(id)sender {
    [self.delegate btnForwardPressed:_indexPath];
}

@end
