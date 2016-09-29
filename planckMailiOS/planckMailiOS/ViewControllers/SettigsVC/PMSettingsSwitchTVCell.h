//
//  PMSwitchTVCell.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSettingsSwitchTVCell;
@protocol PMSettingsSwitchTVCellDelegate <NSObject>

-(void)switchCell:(PMSettingsSwitchTVCell*)cell switchControllValueChanged:(BOOL)value;

@end

@interface PMSettingsSwitchTVCell : UITableViewCell
@property (strong, nonatomic) id<PMSettingsSwitchTVCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISwitch *switchControl;

@property (strong, nonatomic) NSString *tagString;
@end
