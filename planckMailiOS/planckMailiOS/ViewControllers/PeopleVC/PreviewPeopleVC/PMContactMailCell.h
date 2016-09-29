//
//  PMContactMailCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/14/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMContactMailCellDelegate <NSObject>
- (void)didSelectAttachment:(NSDictionary *)file;
@end

@interface PMContactMailCell : UITableViewCell
@property(nonatomic, weak) id<PMContactMailCellDelegate> delegate;
+ (instancetype)newCell;
-(void)bindModel:(NSDictionary*)model email:(NSString*)email;
@end
