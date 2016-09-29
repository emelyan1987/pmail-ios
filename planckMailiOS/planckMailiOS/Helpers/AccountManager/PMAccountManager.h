//
//  PMAccountManager.h
//  planckMailiOS
//
//  Created by LionStar on 12/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMAccountManager : NSObject
+(PMAccountManager*)sharedManager;


-(NSString*)iconNameByProvider:(NSString*)provider;
@end
