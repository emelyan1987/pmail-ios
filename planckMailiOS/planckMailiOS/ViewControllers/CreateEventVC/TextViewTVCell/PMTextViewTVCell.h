//
//  PMTextViewTVCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/30/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMTextViewTVCell;

@protocol PMTextViewTVCellDelegate <NSObject>
- (void)PMTextViewTVCellDelegate:(PMTextViewTVCell *)textViewCell textDidChange:(NSString*)text;
- (void)PMTextViewTVCellDelegate:(PMTextViewTVCell *)textViewCell getFocus:(UITextView*)textView;
@end
@interface PMTextViewTVCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) id<PMTextViewTVCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end
