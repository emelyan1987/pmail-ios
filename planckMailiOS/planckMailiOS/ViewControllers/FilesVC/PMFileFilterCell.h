//
//  PMFileFilterCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMFileFilterCellDelegate <NSObject>
-(void)didFilterButtonPressed:(id)sender;
-(void)didSelectFilterMenu:(NSString*)menuTitle;
@end
@interface PMFileFilterCell : UITableViewCell

@property(nonatomic, weak) id<PMFileFilterCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property (weak, nonatomic) IBOutlet UILabel *lblFilterName;

+ (instancetype)newCell;
-(void)showFilterMenu:(UIView *)view fromRect:(CGRect)rect;

@end
