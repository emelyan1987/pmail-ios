//
//  PMContactMailVC.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/14/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"


@interface PMTrackMailVC : UIViewController

@property NSDictionary *message;

-(id)initWithMessage:(NSDictionary*)message;
@end
