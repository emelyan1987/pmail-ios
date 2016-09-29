//
//  PMInboxMailModel(Extended).h
//  planckMailiOS
//
//  Created by LionStar on 2/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMThread.h"
@interface PMThread(Extended)

- (BOOL)isComeFromSalesforce;
- (BOOL)isReply;
//- (void)isComeFromSalesforce:(void(^)(BOOL value))handler;
- (void)getAdditionalInfo:(NSManagedObjectContext*)context completion:(void(^)(NSDictionary*info))handler;
@end
