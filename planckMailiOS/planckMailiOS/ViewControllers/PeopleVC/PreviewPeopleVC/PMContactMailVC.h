//
//  PMContactMailVC.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/14/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"


@interface PMContactMailVC : UIViewController

@property NSDictionary *message;
@property PMContactModel *contact;

-(id)initWithMessage:(NSDictionary*)message contact:(PMContactModel*)contact;
@end
