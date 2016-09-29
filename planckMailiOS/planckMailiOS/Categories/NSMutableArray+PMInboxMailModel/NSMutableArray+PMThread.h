//
//  NSArray+MailModel.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMThread.h"

@interface NSMutableArray(PMThread)

-(BOOL)changedMail:(PMThread*)mail;
-(BOOL)isContainMail:(PMThread*)mail;
-(void)addMail:(PMThread*)mail;
-(void)changeMail:(PMThread*)mail;
@end
