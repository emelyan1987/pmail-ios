//
//  PMTextFieldTVCell.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMTextFieldTVCell;

@protocol PMTextFieldTVCellDelegate <NSObject>
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString*)text;
- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell getFocus:(UITextField*)textField;
@end

@interface PMTextFieldTVCell : UITableViewCell
@property(nonatomic, weak)id<PMTextFieldTVCellDelegate> delegate;

@property (nonatomic, copy) void (^cellTapAction)(id sender);

@property (weak, nonatomic) IBOutlet UITextField *textField;
@end
