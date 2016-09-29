//
//  PMSettingsTextViewTVCell.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSettingsTextViewTVCell;

@protocol PMSettingsTextViewTVCellDelegate <NSObject>

-(void)textViewCell:(PMSettingsTextViewTVCell*)cell textDidChange:(NSString*)text;

@end
@interface PMSettingsTextViewTVCell : UITableViewCell

@property (strong, nonatomic) id<PMSettingsTextViewTVCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSString *tagString;
@end
