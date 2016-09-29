//
//  WKEventRow.h
//  planckMailiOS
//
//  Created by nazar on 11/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;

@interface WKEventRow : NSObject
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *organizerNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *rowGroup;

@end
