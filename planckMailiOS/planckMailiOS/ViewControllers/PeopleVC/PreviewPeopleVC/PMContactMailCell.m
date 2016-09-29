//
//  PMContactMailCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/14/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactMailCell.h"
#import "PMFileManager.h"
#import "Config.h"

@interface PMContactMailCell()
@property (weak, nonatomic) IBOutlet UILabel *lblWhere;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblSubject;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblFolder;
@property (weak, nonatomic) IBOutlet UIImageView *imgAttach;

@end
@implementation PMContactMailCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMContactMailCell" owner:nil options:nil];
    PMContactMailCell *cell = [cellsXIB firstObject];
    
    return cell;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(NSDictionary *)model email:(NSString *)email
{
    if(![model[@"from"][0][@"email"] isEqual:[NSNull null]] && [email isEqualToString:model[@"from"][0][@"email"]])
        _lblWhere.text = @"From:";
    else if(![model[@"to"][0][@"email"] isEqual:[NSNull null]] && [email isEqualToString:model[@"to"][0][@"email"]])
        _lblWhere.text = @"To:";
    
    _lblEmail.text = notNullEmptyString(email);
    _lblSubject.text = ([model[@"subject"] isEqual:[NSNull null]] || [model[@"subject"] length]==0)? @"(No Subject)" : model[@"subject"];
    _lblText.text = notNullEmptyString(model[@"snippet"]);
    

    _lblTime.text = [PMFileManager RelativeTime:[model[@"date"] doubleValue]];
    
    NSArray *files = model[@"files"];
    _imgAttach.hidden = YES;
    if(files.count>0) _imgAttach.hidden = NO;
    
    //DLog(@"Model:%@", model);
    if(![model[@"folder"] isEqual:[NSNull null]])
        _lblFolder.text = notNullEmptyString(model[@"folder"][@"display_name"]);
    
}
@end
