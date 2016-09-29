//
//  PMPeopleVC.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMPeopleVC : UIViewController

@property (nonatomic, assign) BOOL isPicker;    // Whether is for picking a contact?
@property (nonatomic, strong) NSString *email;  // The email address to register to existing contact
@property (nonatomic, strong) NSString *contactType;
@end
