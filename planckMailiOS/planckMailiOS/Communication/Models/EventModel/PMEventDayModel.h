//
//  PMEventDayModel.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMEventDayModel : NSObject
@property(nonatomic, copy) NSArray *events;
@property(nonatomic, strong) NSDate *date;

@end
