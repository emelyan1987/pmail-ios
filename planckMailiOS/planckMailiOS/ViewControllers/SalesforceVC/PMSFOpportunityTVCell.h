//
//  PMSFOpportunityTVCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMSFOpportunityTVCell : UITableViewCell
-(void)bindItem:(NSDictionary*)itemData locale:(NSLocale*)locale;
@end
