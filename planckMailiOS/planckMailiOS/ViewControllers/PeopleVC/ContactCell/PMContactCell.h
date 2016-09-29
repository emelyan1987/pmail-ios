//
//  PMContactCell.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSavedContact.h"

@interface PMContactCell : UITableViewCell

-(void)bindContact:(DBSavedContact*)contact;
@end
