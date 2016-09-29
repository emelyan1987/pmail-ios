//
//  PMPhoneInputCell.h
//  planckMailiOS
//
//  Created by LionStar on 1/8/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMPhoneInputCell : UITableViewCell
@property (nonatomic, copy) void (^btnTitleTapAction)(id sender);
@property (nonatomic, copy) void (^textFieldDidChange)(id sender, NSString *text);
@property (nonatomic, copy) void (^btnDeleteTapAction)(id sender);
@property (nonatomic, copy) void (^btnDeleteConfirmTapAction)(id sender);
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeadingConstraint;

-(void)bindData:(NSDictionary*)data deleteConfirmStatus:(BOOL)status;

@end
