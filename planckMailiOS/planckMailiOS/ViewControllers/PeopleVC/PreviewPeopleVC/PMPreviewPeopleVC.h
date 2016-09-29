//
//  PMPreviewPeopleVC.h
//  planckMailiOS
//
//  Created by admin on 6/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMContactModel.h"
#import "DBSavedContact.h"



@interface PMPreviewPeopleVC : UIViewController
@property (nonatomic, strong) PMContactModel *model;
@property (nonatomic, strong) DBSavedContact *contact;
@end
