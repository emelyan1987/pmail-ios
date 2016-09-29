//
//  PMSFOpportunityTVCell.m
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFOpportunityTVCell.h"
#import "PMTextManager.h"
#import <NSDate+DateTools.h>

@interface PMSFOpportunityTVCell()
@property (weak, nonatomic) IBOutlet UILabel *lblOpportunityName;
@property (weak, nonatomic) IBOutlet UILabel *lblAccountName;
@property (weak, nonatomic) IBOutlet UILabel *lblCloseDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblProbability;
@property (weak, nonatomic) IBOutlet UILabel *lblLastActivityDate;

@end
@implementation PMSFOpportunityTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)bindItem:(NSDictionary *)itemData locale:(NSLocale*)locale
{
    [_lblOpportunityName setText:itemData[@"Name"]];
    [_lblAccountName setText:itemData[@"AccountName"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _lblLastActivityDate.text = @"";
    if(itemData[@"LastActivityDate"])
    {
        NSDate *lastActivityDate = [dateFormatter dateFromString:itemData[@"LastActivityDate"]];
        
        _lblLastActivityDate.text = [NSString stringWithFormat:@"Last activity was %@", [lastActivityDate timeAgoSinceDate:[NSDate date]]];
    }
    
    NSDate *closeDate = [dateFormatter dateFromString:itemData[@"CloseDate"]];
    [dateFormatter setDateFormat:@"MMM d,yyyy"];
    [_lblCloseDate setText:[dateFormatter stringFromDate:closeDate]];
    
    [_lblProbability setText:itemData[@"Probability"]?[NSString stringWithFormat:@"%d%%", [itemData[@"Probability"] intValue]]:@""];
    [_lblAmount setText:itemData[@"Amount"]?[self getFormattedAmount:itemData[@"Amount"] locale:locale]:@""];
}

-(NSString*)getFormattedAmount:(NSNumber*)amount locale:(NSLocale*)locale
{
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setLocale:locale];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *amountString = [currencyFormatter stringFromNumber:amount];
    
    return amountString;
}
@end
